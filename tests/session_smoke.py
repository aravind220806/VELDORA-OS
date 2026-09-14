"""Run explicitly in an isolated test bus with the Veldora shell already running.

DBUS_SESSION_BUS_ADDRESS=<test bus> python tests/session_smoke.py
Sends test notifications only; it never changes sound/brightness or host settings.
"""
from gi.repository import Gio, GLib

connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
events = []
subscription = connection.signal_subscribe(
    "org.freedesktop.Notifications", "org.freedesktop.Notifications", "NotificationClosed",
    "/org/freedesktop/Notifications", None, Gio.DBusSignalFlags.NONE,
    lambda _c, _s, _p, _i, _m, params: events.append(params.unpack()),
)


def call(method, params=None):
    return connection.call_sync(
        "org.freedesktop.Notifications", "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications", method, params, None,
        Gio.DBusCallFlags.NONE, 3000, None,
    ).unpack()


def notify(replaces=0, timeout=0):
    return call("Notify", GLib.Variant("(susssasa{sv}i)", (
        "Veldora test", replaces, "", "<b>Plain text</b>",
        "Notification lifecycle test", [], {}, timeout,
    )))[0]


assert call("GetCapabilities") == (["body"],)
assert call("GetServerInformation")[0] == "Veldora Island"
first = notify()
assert notify(first) == first, "Replacement should preserve the ID"
call("CloseNotification", GLib.Variant("(u)", (first,)))
expired = notify(timeout=1000)
loop = GLib.MainLoop()
GLib.timeout_add(1500, lambda: (loop.quit(), False)[1])
loop.run()
assert (first, 3) in events, f"Missing explicit-close signal: {events}"
assert (expired, 1) in events, f"Missing expiration signal: {events}"
connection.signal_unsubscribe(subscription)
print("Session smoke passed: capabilities, server identity, replacement, close signal, expiration signal.")
