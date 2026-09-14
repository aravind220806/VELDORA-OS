#!/usr/bin/env python3
"""Veldora security workbench, using the desktop's existing GTK runtime."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import shutil
import sys
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Gio, GLib
from core import TOOLS, find_tools, launch, create_engagement, hash_evidence, system_checks

HERE = Path(__file__).resolve().parent


def label(text, style=None):
    widget = Gtk.Label(label=text, xalign=0)
    widget.set_line_wrap(True)
    if style:
        widget.get_style_context().add_class(style)
    return widget


def column(spacing=14):
    return Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=spacing)


class Workbench(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.veldora.Workbench')
        self.pool = ThreadPoolExecutor(max_workers=2)
        self.engagement = None

    def do_activate(self):
        if self.get_active_window():
            self.get_active_window().present()
            return
        Gtk.Settings.get_default().set_property('gtk-application-prefer-dark-theme', True)
        css = Gtk.CssProvider()
        css.load_from_path(str(HERE / 'style.css'))
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        win = Gtk.ApplicationWindow(application=self, title='Veldora • Security Workbench')
        win.set_default_size(1120, 760)
        outer = column(0)
        win.add(outer)
        header = Gtk.HeaderBar(title='VELDORA', subtitle='Security Workbench', show_close_button=True)
        win.set_titlebar(header)
        content = Gtk.Box(spacing=24)
        content.set_border_width(24)
        outer.pack_start(content, True, True, 0)
        self.stack = Gtk.Stack(transition_type=Gtk.StackTransitionType.NONE)
        sidebar = column(24)
        sidebar.set_size_request(185, -1)
        sidebar.pack_start(label('FIELD STATION / 01', 'eyebrow'), False, False, 0)
        switcher = Gtk.StackSidebar(stack=self.stack)
        sidebar.pack_start(switcher, True, True, 0)
        sidebar.pack_start(label('HYPRLAND EDITION\nLocal tools. Clear evidence.', 'muted'), False, False, 0)
        content.pack_start(sidebar, False, False, 0)
        content.pack_start(self.stack, True, True, 0)
        self.status = label('Ready • Super + S opens this workbench', 'status')
        self.status.set_margin_start(24)
        self.status.set_margin_bottom(16)
        outer.pack_end(self.status, False, False, 0)
        self.tools_page()
        self.engagement_page()
        self.checks_page()
        win.show_all()

    def page(self, name, title, description):
        box = column()
        box.pack_start(label(title, 'title'), False, False, 0)
        box.pack_start(label(description, 'muted'), False, False, 0)
        self.stack.add_titled(box, name, name)
        return box

    def action(self, title, callback):
        button = Gtk.Button(label=title)
        button.connect('clicked', lambda *_: self.guard(callback))
        return button

    def guard(self, callback):
        try:
            callback()
        except (OSError, ValueError, GLib.Error) as error:
            self.status.set_text(str(error))

    def tools_page(self):
        page = self.page('Toolkit', 'Your next investigation starts here.',
            'Explore tools by discipline. Terminal tools open their help; choose targets and options yourself.')
        controls = Gtk.Box(spacing=12)
        self.search = Gtk.SearchEntry(placeholder_text='Search tools, capabilities, disciplines…')
        self.search.connect('search-changed', lambda *_: self.refresh_tools())
        self.category = Gtk.ComboBoxText()
        for category in ['All'] + sorted({t.category for t in TOOLS}):
            self.category.append_text(category)
        self.category.set_active(0)
        self.category.connect('changed', lambda *_: self.refresh_tools())
        controls.pack_start(self.search, True, True, 0)
        controls.pack_start(self.category, False, False, 0)
        page.pack_start(controls, False, False, 0)
        self.count = label('', 'eyebrow')
        page.pack_start(self.count, False, False, 0)
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.rows = Gtk.ListBox(selection_mode=Gtk.SelectionMode.NONE)
        scroll.add(self.rows)
        page.pack_start(scroll, True, True, 0)
        self.refresh_tools()

    def refresh_tools(self):
        for row in self.rows.get_children():
            self.rows.remove(row)
        matches = find_tools(self.search.get_text(), self.category.get_active_text())
        ready = sum(bool(shutil.which(t.argv[0])) for t in TOOLS)
        self.count.set_text(f'{len(matches)} TOOLS SHOWN   /   {ready} OF {len(TOOLS)} AVAILABLE')
        for tool in matches:
            row = Gtk.Box(spacing=16)
            row.set_border_width(14)
            text = column(5)
            text.pack_start(label(tool.name, 'tool-name'), False, False, 0)
            text.pack_start(label(f'{tool.category} · {tool.description}', 'muted'), False, False, 0)
            row.pack_start(text, True, True, 0)
            installed = bool(shutil.which(tool.argv[0]))
            button = self.action('Open' if tool.gui else 'Open help', lambda t=tool: self.open_tool(t))
            button.set_sensitive(installed)
            button.set_tooltip_text(f'Package: {tool.package}')
            if not installed:
                text.pack_start(label(f'Not installed · {tool.package}', 'muted'), False, False, 0)
            row.pack_end(button, False, False, 0)
            self.rows.add(row)
        if not matches:
            self.rows.add(label('No matching tools. Try another search or discipline.'))
        self.rows.show_all()

    def open_tool(self, tool):
        launch(tool, self.engagement)
        self.status.set_text(f'Opened {tool.name}')

    def engagement_page(self):
        page = self.page('Engagements', 'Give every investigation a home.',
            'Private folders for scope, notes, captures, evidence and reports. Stored locally in ~/Engagements.')
        self.name = Gtk.Entry(placeholder_text='Engagement name, e.g. lab-2026-09')
        self.scope = Gtk.Entry(placeholder_text='Authorized assets, exclusions and testing window')
        page.pack_start(label('NAME', 'eyebrow'), False, False, 0)
        page.pack_start(self.name, False, False, 0)
        page.pack_start(label('SCOPE', 'eyebrow'), False, False, 0)
        page.pack_start(self.scope, False, False, 0)
        page.pack_start(self.action('Create engagement', self.create), False, False, 0)
        page.pack_start(self.action('Open engagements folder', self.open_folder), False, False, 0)
        page.pack_start(label('Evidence fingerprint', 'title-small'), False, False, 0)
        page.pack_start(label('Calculate a file’s SHA-256 without modifying it. A fingerprint detects changes; it does not establish chain of custody.', 'muted'), False, False, 0)
        page.pack_start(self.action('Choose file and calculate SHA-256', self.choose_evidence), False, False, 0)
        self.digest = label('No file selected.', 'mono')
        self.digest.set_selectable(True)
        self.digest.set_line_wrap_mode(2)
        page.pack_start(self.digest, False, False, 0)

    def create(self):
        self.engagement = create_engagement(Path.home() / 'Engagements', self.name.get_text(), self.scope.get_text())
        self.status.set_text(f'Active engagement: {self.engagement} • Tools start in this folder')

    def open_folder(self):
        root = Path.home() / 'Engagements'
        root.mkdir(exist_ok=True, mode=0o700)
        Gio.AppInfo.launch_default_for_uri(root.as_uri(), None)

    def background(self, work, done):
        future = self.pool.submit(work)
        def finished(result):
            try:
                value = result.result()
            except Exception as error:
                GLib.idle_add(self.status.set_text, str(error))
            else:
                GLib.idle_add(done, value)
        future.add_done_callback(finished)

    def choose_evidence(self):
        dialog = Gtk.FileChooserDialog(title='Select evidence file', transient_for=self.get_active_window(),
            action=Gtk.FileChooserAction.OPEN)
        dialog.add_buttons('Cancel', Gtk.ResponseType.CANCEL, 'Calculate', Gtk.ResponseType.OK)
        if dialog.run() == Gtk.ResponseType.OK:
            path = dialog.get_filename()
            self.digest.set_text('Calculating…')
            self.background(lambda: hash_evidence(path), lambda value: self.digest.set_text(f'{path}\nSHA-256\n{value}'))
        dialog.destroy()

    def checks_page(self):
        page = self.page('System checks', 'Observe before you act.',
            'On-demand local diagnostics. These observations are not an intrusion detector or a security score.')
        page.pack_start(self.action('Refresh local checks', self.refresh_checks), False, False, 0)
        scroll = Gtk.ScrolledWindow()
        self.check_text = Gtk.TextView(editable=False, cursor_visible=False, monospace=True, wrap_mode=Gtk.WrapMode.WORD_CHAR)
        self.check_text.get_buffer().set_text('Run checks to inspect services, listening sockets, connections and firewall service state.')
        scroll.add(self.check_text)
        page.pack_start(scroll, True, True, 0)
        self.checks_busy = False

    def refresh_checks(self):
        if self.checks_busy:
            return
        self.checks_busy = True
        self.status.set_text('Reading local system state…')
        def done(results):
            self.checks_busy = False
            self.check_text.get_buffer().set_text('\n\n'.join(f'{title}\n{output}' for title, output in results))
            self.status.set_text('Local checks complete • No settings changed')
        self.background(system_checks, done)


if __name__ == '__main__':
    app = Workbench()
    code = app.run(sys.argv)
    app.pool.shutdown(wait=False, cancel_futures=True)
    sys.exit(code)
