#!/usr/bin/env python3
"""Veldora's live desktop: GTK layer surfaces and a session notification server."""
import argparse
import datetime
import json
import shutil
import os
from pathlib import Path
import signal
import sys

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("GtkLayerShell", "0.1")
gi.require_foreign("cairo")
from gi.repository import Gdk, GdkPixbuf, Gio, GLib, Gtk, GtkLayerShell as Layer, Pango
import cairo
from model import Notifications

HERE = Path(__file__).resolve().parent
BUS = "org.veldora.Shell"
CONTROL = {
    "volume-up": ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+"],
    "volume-down": ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"],
    "mute": ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"],
    "brightness-up": ["brightnessctl", "--class=backlight", "set", "+5%"],
    "brightness-down": ["brightnessctl", "--class=backlight", "--min-value=1", "set", "5%-"],
}


def run(argv, done=None):
    """Never pass app metadata through a shell. Keep subprocesses off GTK's loop."""
    try:
        proc = Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE)
    except GLib.Error as error:
        if done:
            done(False, str(error))
        return

    def finished(proc, result):
        try:
            _, out, err = proc.communicate_utf8_finish(result)
            if done:
                done(proc.get_successful(), (out if proc.get_successful() else err).strip())
        except GLib.Error as error:
            if done:
                done(False, str(error))
    proc.communicate_utf8_async(None, None, finished)


def label(text="", css=None):
    widget = Gtk.Label(label=text)
    if css:
        widget.get_style_context().add_class(css)
    return widget


def button(icon, tooltip, callback):
    widget = Gtk.Button()
    widget.set_image(Gtk.Image.new_from_icon_name(icon, Gtk.IconSize.LARGE_TOOLBAR))
    widget.set_tooltip_text(tooltip)
    widget.get_accessible().set_name(tooltip)
    widget.connect("clicked", lambda *_: callback())
    return widget


def box(vertical=False, spacing=6, css=None):
    widget = Gtk.Box(orientation=Gtk.Orientation.VERTICAL if vertical else Gtk.Orientation.HORIZONTAL, spacing=spacing)
    if css:
        widget.get_style_context().add_class(css)
    return widget


def surface(namespace, edge, layer=Layer.Layer.TOP, margin=12, reserve=False):
    window = Gtk.Window()
    window.set_app_paintable(True)
    window.set_visual(window.get_screen().get_rgba_visual())
    window.set_resizable(False)
    Layer.init_for_window(window)
    Layer.set_namespace(window, namespace)
    Layer.set_layer(window, layer)
    Layer.set_anchor(window, edge, True)
    Layer.set_margin(window, edge, margin)
    Layer.set_keyboard_mode(window, Layer.KeyboardMode.ON_DEMAND)
    if reserve:
        Layer.auto_exclusive_zone_enable(window)
    return window


class Shell:
    def __init__(self):
        self.notifications = Notifications()
        self.timers = {}
        self.osd_timer = None
        self.media = ""
        self.manual_open = False
        self.cpu_previous = None
        self.status_busy = False
        self.workspace_busy = False
        self.media_busy = False
        self.connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        self.windows = []
        provider = Gtk.CssProvider()
        provider.load_from_path(str(HERE / "style.css"))
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self.build_desktop()
        self.build_island()
        self.build_panels()
        for window in self.windows:
            window.show_all()
        self.popup.hide()
        self.details.set_reveal_child(False)
        self.tick()
        self.refresh_status()
        GLib.timeout_add_seconds(5, self.refresh_status)
        self.refresh_workspaces()
        self.watch_workspaces()
        GLib.timeout_add_seconds(15, self.tick)
        self.poll_media()
        GLib.timeout_add_seconds(2, self.poll_media)
        self.register_bus()

    def build_desktop(self):
        background = surface("veldora-background", Layer.Edge.TOP, Layer.Layer.BACKGROUND, 0)
        Layer.set_exclusive_zone(background, -1)
        for edge in (Layer.Edge.BOTTOM, Layer.Edge.LEFT, Layer.Edge.RIGHT):
            Layer.set_anchor(background, edge, True)
        Layer.set_keyboard_mode(background, Layer.KeyboardMode.NONE)
        art = Gtk.DrawingArea()
        art.connect("draw", self.draw_wallpaper)
        background.add(art)
        self.windows.append(background)
        self.wallpaper = None
        wallpaper = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "veldora/wallpaper"
        if wallpaper.is_file():
            try:
                self.wallpaper = GdkPixbuf.Pixbuf.new_from_file(str(wallpaper))
            except GLib.Error as error:
                print(f"Wallpaper unavailable: {error}", file=sys.stderr)

    def draw_wallpaper(self, widget, cr):
        cr.set_source_rgb(0.015, 0.015, 0.020)
        cr.paint()
        if self.wallpaper:
            width, height = widget.get_allocated_width(), widget.get_allocated_height()
            pw, ph = self.wallpaper.get_width(), self.wallpaper.get_height()
            scale = max(width / pw, height / ph)
            cr.translate((width - pw * scale) / 2, (height - ph * scale) / 2)
            cr.scale(scale, scale)
            Gdk.cairo_set_source_pixbuf(cr, self.wallpaper, 0, 0)
            cr.paint()
        return False

    def build_island(self):
        window = surface("veldora-island", Layer.Edge.TOP, margin=4, reserve=False)
        # Reserve compact height only; opening the island overlays apps without retiling.
        Layer.set_exclusive_zone(window, 36)
        outer = box(True, 0, "island")
        self.header = Gtk.Button()
        row = box(False, 14)
        self.title = label("", "island-title")
        self.title.set_max_width_chars(34)
        self.title.set_ellipsize(Pango.EllipsizeMode.END)
        row.pack_start(self.title, True, True, 0)
        self.header.add(row)
        self.header.connect("clicked", lambda *_: self.toggle())
        outer.pack_start(self.header, False, False, 0)
        self.details = Gtk.Revealer()
        self.details.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
        self.details.set_transition_duration(220)
        detail = box(True, 10, "detail")
        detail.set_size_request(350, -1)
        detail.pack_start(label("NOW PLAYING", "section"), False, False, 0)
        self.track = label("No media playing", "track")
        self.track.set_max_width_chars(27)
        self.track.set_ellipsize(Pango.EllipsizeMode.END)
        detail.pack_start(self.track, False, False, 0)
        controls = box()
        controls.set_halign(Gtk.Align.CENTER)
        for icon, tip, command in [
            ("media-skip-backward-symbolic", "Previous track", "previous"),
            ("media-playback-start-symbolic", "Play or pause", "play-pause"),
            ("media-skip-forward-symbolic", "Next track", "next"),
        ]:
            controls.pack_start(button(icon, tip, lambda c=command: self.launch(["playerctl", c])), False, False, 0)
        detail.pack_start(controls, False, False, 0)
        detail.pack_start(Gtk.Separator(), False, False, 0)
        settings = box()
        for icon, tip, action in [
            ("audio-volume-low-symbolic", "Lower volume", "volume-down"),
            ("audio-volume-muted-symbolic", "Mute or unmute", "mute"),
            ("audio-volume-high-symbolic", "Raise volume", "volume-up"),
            ("display-brightness-symbolic", "Lower brightness", "brightness-down"),
            ("weather-clear-symbolic", "Raise brightness", "brightness-up"),
        ]:
            settings.pack_start(button(icon, tip, lambda a=action: self.control(a)), True, True, 0)
        detail.pack_start(settings, False, False, 0)
        detail.pack_start(label("NOTIFICATIONS", "section"), False, False, 0)
        self.notices = box(True)
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_min_content_height(90)
        scroll.set_max_content_height(230)
        scroll.set_propagate_natural_height(True)
        scroll.add(self.notices)
        detail.pack_start(scroll, False, False, 0)
        close = Gtk.Button(label="Collapse island")
        close.connect("clicked", lambda *_: self.toggle())
        detail.pack_start(close, False, False, 0)
        self.details.add(detail)
        self.popup = surface("veldora-details", Layer.Edge.TOP, margin=44)
        Layer.set_exclusive_zone(self.popup, -1)
        popup_box = box(True, 0, "expanded")
        popup_box.pack_start(self.details, False, False, 0)
        self.popup.add(popup_box)
        self.popup.connect("key-press-event", self.keypress)
        self.windows.append(self.popup)
        window.add(outer)
        window.connect("key-press-event", self.keypress)
        self.windows.append(window)
        self.render_notifications()

    def keypress(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.set_open(False)
            return True
        return False

    def side_panel(self, name, side):
        window = surface(name, Layer.Edge.TOP, margin=4)
        Layer.set_exclusive_zone(window, -1)
        Layer.set_anchor(window, side, True)
        Layer.set_margin(window, side, 8)
        content = box(False, 5)
        window.add(content)
        self.windows.append(window)
        return content

    def build_panels(self):
        left = self.side_panel("veldora-left", Layer.Edge.LEFT)
        workspaces = box(False, 0, "panel")
        self.workspace_buttons = {}
        for number in range(1, 11):
            item = Gtk.Button(label=str(number))
            item.set_tooltip_text(f"Workspace {number} · Super+{number % 10}")
            item.connect("clicked", lambda _b, n=number: self.launch(["hyprctl", "dispatch", f"hl.dsp.focus({{ workspace = {n} }})"]))
            self.workspace_buttons[number] = item
            workspaces.pack_start(item, False, False, 0)
        left.pack_start(workspaces, False, False, 0)
        self.stats = label("CPU —   RAM —   °C —   / —", "stats")
        self.stats.set_tooltip_text("CPU usage · RAM usage · CPU temperature · root disk usage")
        stat_button = Gtk.Button()
        stat_button.get_style_context().add_class("panel")
        stat_button.add(self.stats)
        stat_button.connect("clicked", lambda *_: self.launch(["foot", "-e", "top"]))
        left.pack_start(stat_button, False, False, 0)
        self.stat_button = stat_button
        right = self.side_panel("veldora-right", Layer.Edge.RIGHT)
        group = box(False, 0, "panel")
        self.sound_button = button("audio-volume-high-symbolic", "Sound settings", lambda: self.launch(["pavucontrol"]))
        self.network_button = button("network-offline-symbolic", "Network · connect with nmtui", lambda: self.launch(["foot", "-e", "nmtui"]))
        for item in (self.sound_button, self.network_button,
                     button("bluetooth-symbolic", "Bluetooth settings", lambda: self.launch(["blueman-manager"]))):
            item.get_image().set_pixel_size(16)
            group.pack_start(item, False, False, 0)
        right.pack_start(group, False, False, 0)
        self.battery = Gtk.Button(label="AC")
        self.battery.get_style_context().add_class("panel")
        self.battery.connect("clicked", lambda *_: self.toggle())
        right.pack_start(self.battery, False, False, 0)
        power = button("system-shutdown-symbolic", "Session and power", self.power_menu)
        power.get_image().set_pixel_size(16)
        power.get_style_context().add_class("panel")
        right.pack_start(power, False, False, 0)
        # Preserve launch/settings access without a desktop dock.
        apps = box()
        for icon, tip, argv in [
            ("view-app-grid-symbolic", "Search apps", ["fuzzel"]),
            ("utilities-terminal-symbolic", "Terminal", ["foot"]),
            ("folder-symbolic", "Files", ["thunar"]),
            ("system-lock-screen-symbolic", "Lock screen", ["hyprlock"]),
        ]:
            apps.pack_start(button(icon, tip, lambda a=argv: self.launch(a)), True, True, 0)
        self.details.get_child().pack_start(apps, False, False, 0)
        monitor = Gdk.Display.get_default().get_primary_monitor() or Gdk.Display.get_default().get_monitor(0)
        self.compact_panel = monitor.get_geometry().width < 1500
        if self.compact_panel:
            self.stat_button.set_no_show_all(True)
            self.stat_button.hide()
            # Metrics remain accessible inside the island on smaller displays.
            self.popup_stats = label("", "body")
            self.details.get_child().pack_start(self.popup_stats, False, False, 0)

    def refresh_workspaces(self):
        if self.workspace_busy:
            return
        self.workspace_busy = True
        def occupied(ok, text):
            try:
                occupied_ids = {w["id"] for w in json.loads(text)} if ok else set()
            except (ValueError, KeyError, TypeError):
                occupied_ids = set()
            def active(ok, text):
                self.workspace_busy = False
                try:
                    current = json.loads(text).get("id") if ok else None
                except (ValueError, AttributeError):
                    current = None
                for n, item in self.workspace_buttons.items():
                    context = item.get_style_context()
                    for cls, enabled in (("active", n == current), ("occupied", n in occupied_ids)):
                        (context.add_class if enabled else context.remove_class)(cls)
            run(["hyprctl", "-j", "activeworkspace"], active)
        run(["hyprctl", "-j", "workspaces"], occupied)

    def watch_workspaces(self):
        signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
        if not signature:
            return False
        path = f"{os.environ.get('XDG_RUNTIME_DIR', '/run/user/' + str(os.getuid()))}/hypr/{signature}/.socket2.sock"
        client = Gio.SocketClient()
        def connected(client, result):
            try:
                self.workspace_socket = client.connect_finish(result)
                stream = Gio.DataInputStream.new(self.workspace_socket.get_input_stream())
            except GLib.Error:
                GLib.timeout_add_seconds(5, self.watch_workspaces)
                return
            def received(stream, result):
                try:
                    data, _length = stream.read_line_finish_utf8(result)
                except GLib.Error:
                    data = None
                if data is None:
                    self.workspace_socket.close(None)
                    GLib.timeout_add_seconds(5, self.watch_workspaces)
                    return
                if data.startswith(("workspace", "focusedmon", "openwindow", "closewindow", "movewindow", "createworkspace", "destroyworkspace")):
                    self.refresh_workspaces()
                stream.read_line_async(GLib.PRIORITY_DEFAULT, None, received)
            stream.read_line_async(GLib.PRIORITY_DEFAULT, None, received)
        client.connect_async(Gio.UnixSocketAddress.new(path), None, connected)
        return False

    def refresh_status(self):
        try:
            cpu = [int(x) for x in Path("/proc/stat").read_text().splitlines()[0].split()[1:9]]
            total, idle = sum(cpu), cpu[3] + cpu[4]
            usage = "—"
            if self.cpu_previous and total > self.cpu_previous[0]:
                usage = str(round(100 * (1 - (idle-self.cpu_previous[1]) / (total-self.cpu_previous[0])))) + "%"
            self.cpu_previous = (total, idle)
            mem = dict((line.split(':')[0], int(line.split()[1])) for line in Path('/proc/meminfo').read_text().splitlines())
            ram = round(100 * (1 - mem['MemAvailable'] / mem['MemTotal']))
            disk = shutil.disk_usage('/')
            temperature = "—"
            for zone in Path('/sys/class/thermal').glob('thermal_zone*'):
                if (zone/'type').read_text().strip() in ('x86_pkg_temp', 'cpu-thermal', 'cpu_thermal'):
                    temperature = str(round(int((zone/'temp').read_text()) / 1000)) + '°'
                    break
            self.stats.set_text(f"CPU {usage}   RAM {ram}%   {temperature}   / {round(disk.used/disk.total*100)}%")
            if hasattr(self, 'popup_stats'):
                self.popup_stats.set_text(self.stats.get_text())
            batteries = [p for p in Path('/sys/class/power_supply').glob('*') if (p/'type').read_text().strip() == 'Battery']
            if batteries:
                battery = batteries[0]
                self.battery.set_label((battery/'capacity').read_text().strip() + '%')
                self.battery.set_tooltip_text((battery/'status').read_text().strip())
            else:
                self.battery.set_label('AC')
                self.battery.set_tooltip_text('No battery reported')
        except (OSError, ValueError, KeyError, ZeroDivisionError):
            self.stats.set_tooltip_text('Some system sensors are unavailable')
        if not self.status_busy:
            self.status_busy = True
            def network(ok, text):
                connected = ok and any(line.endswith(':connected') for line in text.splitlines())
                wireless = connected and any(line.startswith('wifi:connected') for line in text.splitlines())
                icon = 'network-wireless-signal-excellent-symbolic' if wireless else ('network-wired-symbolic' if connected else 'network-offline-symbolic')
                self.network_button.get_image().set_from_icon_name(icon, Gtk.IconSize.MENU)
                self.network_button.set_tooltip_text(('Connected' if connected else 'Offline') + ' · click to manage network')
                self.status_busy = False
            run(['nmcli', '-t', '-f', 'TYPE,STATE', 'device'], network)
            def volume(ok, text):
                self.sound_button.set_tooltip_text(text if ok else 'Audio unavailable · open settings')
                self.sound_button.get_image().set_from_icon_name('audio-volume-muted-symbolic' if 'MUTED' in text else 'audio-volume-high-symbolic', Gtk.IconSize.MENU)
            run(['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@'], volume)
        return True

    def power_menu(self):
        dialog = Gtk.MessageDialog(transient_for=self.windows[-1], modal=True, message_type=Gtk.MessageType.QUESTION,
                                   buttons=Gtk.ButtonsType.CANCEL, text="Session and power")
        dialog.format_secondary_text("Choose an action. Restart and power off close your running applications.")
        for title, response in (("Lock", 1), ("Suspend", 2), ("Restart", 3), ("Power off", 4)):
            dialog.add_button(title, response)
        def respond(dialog, response):
            dialog.destroy()
            commands = {1: ['hyprlock'], 2: ['systemctl', 'suspend'], 3: ['systemctl', 'reboot'], 4: ['systemctl', 'poweroff']}
            if response in commands:
                self.launch(commands[response])
        dialog.connect('response', respond)
        dialog.show_all()

    def set_open(self, opened):
        self.manual_open = opened
        if opened:
            self.popup.show_all()
            self.details.set_reveal_child(True)
        else:
            self.details.set_reveal_child(False)
            self.popup.hide()

    def toggle(self):
        self.set_open(not self.manual_open)

    def tick(self):
        if not self.osd_timer:
            self.title.set_text(datetime.datetime.now().strftime("%a, %d/%m · %H:%M"))
        return True

    def launch(self, argv):
        run(argv, lambda ok, out: None if ok else self.osd("Could not open: " + argv[0]))

    def osd(self, text):
        if self.osd_timer:
            GLib.source_remove(self.osd_timer)
        self.title.set_text(text)
        def reset():
            self.osd_timer = None
            self.tick()
            return False
        self.osd_timer = GLib.timeout_add_seconds(5, reset)

    def control(self, action):
        if action not in CONTROL:
            return
        def updated(ok, _out):
            if not ok:
                self.osd("Control unavailable on this device")
            elif action.startswith("brightness"):
                run(["brightnessctl", "--class=backlight", "-m"], lambda ok, out: self.osd("Brightness  " + out.split(",")[3] if ok and len(out.split(",")) >= 4 else "Brightness updated"))
            else:
                run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], lambda ok, out: self.osd(out if ok else "Audio updated"))
        run(CONTROL[action], updated)

    def poll_media(self):
        if not self.media_busy:
            self.media_busy = True
            def received(ok, output):
                self.media_busy = False
                previous = self.media
                self.media = output[:140] if ok and output else ""
                self.track.set_text(output[:140] if ok and output else "No media playing")
                if self.media and self.media != previous and not self.osd_timer:
                    self.osd(self.media)
            run(["playerctl", "metadata", "--format", "{{artist}} · {{title}}"], received)
        return True

    def render_notifications(self):
        for child in self.notices.get_children():
            child.destroy()
        if not self.notifications.items:
            self.notices.pack_start(label("You're all caught up", "body"), False, False, 16)
        for ident, (app, title, body) in reversed(self.notifications.items.items()):
            card = box(True, 3, "notice")
            heading = box()
            title_label = label(title, "island-title")
            title_label.set_ellipsize(Pango.EllipsizeMode.END)
            title_label.set_max_width_chars(26)
            heading.pack_start(title_label, True, True, 0)
            heading.pack_end(button("window-close-symbolic", "Dismiss notification", lambda i=ident: self.close_notification(i, 2)), False, False, 0)
            card.pack_start(heading, False, False, 0)
            if body:
                text = label(body, "body")
                text.set_line_wrap(True)
                text.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR)
                text.set_max_width_chars(32)
                card.pack_start(text, False, False, 0)
            card.pack_start(label(app, "section"), False, False, 0)
            self.notices.pack_start(card, False, False, 0)
        self.notices.show_all()

    def close_notification(self, ident, reason):
        timer = self.timers.pop(ident, None)
        if timer:
            GLib.source_remove(timer)
        if self.notifications.close(ident):
            self.connection.emit_signal(None, "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "NotificationClosed", GLib.Variant("(uu)", (ident, reason)))
            self.render_notifications()

    def register_bus(self):
        info = Gio.DBusNodeInfo.new_for_xml((HERE / "notifications.xml").read_text())
        self.connection.register_object("/org/freedesktop/Notifications", info.interfaces[0], self.notification_call, None, None)
        self.owner = Gio.bus_own_name_on_connection(self.connection, "org.freedesktop.Notifications", Gio.BusNameOwnerFlags.NONE, None, lambda *_: self.osd("Another notification service is running"))
        xml = '<node><interface name="org.veldora.Shell"><method name="Toggle"/><method name="Control"><arg type="s" direction="in"/></method></interface></node>'
        info = Gio.DBusNodeInfo.new_for_xml(xml)
        self.connection.register_object("/org/veldora/Shell", info.interfaces[0], self.shell_call, None, None)

    def shell_call(self, _conn, _sender, _path, _iface, method, params, invocation):
        if method == "Toggle":
            self.toggle()
        elif method == "Control":
            self.control(params.unpack()[0])
        invocation.return_value(None)

    def notification_call(self, _conn, _sender, _path, _iface, method, params, invocation):
        if method == "GetCapabilities":
            invocation.return_value(GLib.Variant("(as)", (["body"],)))
        elif method == "GetServerInformation":
            invocation.return_value(GLib.Variant("(ssss)", ("Veldora Island", "Veldora", "0.1.0", "1.2")))
        elif method == "CloseNotification":
            self.close_notification(params.unpack()[0], 3)
            invocation.return_value(None)
        elif method == "Notify":
            app, replaces, _icon, title, body, _actions, hints, timeout = params.unpack()
            ident, evicted = self.notifications.add(replaces, app, title, body)
            if evicted is not None:
                timer = self.timers.pop(evicted, None)
                if timer:
                    GLib.source_remove(timer)
                self.connection.emit_signal(None, "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "NotificationClosed", GLib.Variant("(uu)", (evicted, 1)))
            timer = self.timers.pop(ident, None)
            if timer:
                GLib.source_remove(timer)
            if timeout != 0 and hints.get("urgency") != 2:
                def expire():
                    self.timers.pop(ident, None)
                    self.close_notification(ident, 1)
                    return False
                self.timers[ident] = GLib.timeout_add(max(1000, min(timeout if timeout > 0 else 10000, 86400000)), expire)
            self.render_notifications()
            self.osd(title[:160])
            invocation.return_value(GLib.Variant("(u)", (ident,)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--toggle", action="store_true")
    parser.add_argument("--control", choices=CONTROL)
    args = parser.parse_args()
    connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    if args.toggle or args.control:
        try:
            connection.call_sync(BUS, "/org/veldora/Shell", BUS, "Control" if args.control else "Toggle", GLib.Variant("(s)", (args.control,)) if args.control else None, None, Gio.DBusCallFlags.NONE, 2000, None)
        except GLib.Error:
            sys.exit("Veldora shell is not running in this session")
        return
    # Acquire synchronously before creating surfaces: avoid duplicate docks on restart.
    result = connection.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "RequestName", GLib.Variant("(su)", (BUS, 4)), GLib.VariantType.new("(u)"), Gio.DBusCallFlags.NONE, 2000, None)
    if result.unpack()[0] != 1:
        sys.exit("Veldora shell is already running")
    if not Layer.is_supported():
        sys.exit("Run Veldora inside a Wayland compositor supporting layer-shell")
    shell = Shell()
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, lambda: (Gtk.main_quit(), False)[1])
    Gtk.main()


if __name__ == "__main__":
    main()
