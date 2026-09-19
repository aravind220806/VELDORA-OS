// SPDX-License-Identifier: GPL-3.0-or-later
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import "EventModel.js" as Events
Singleton {
    id: root
    property var history: []
    property double now: Date.now()
    property bool opened: false
    property string page: "Media"
    property var selected: null
    property bool privacyVeil: false
    readonly property bool locked: GlobalStates.screenLocked
    readonly property bool fullscreen: ToplevelManager.activeToplevel?.fullscreen ?? false
    readonly property var primary: Quickshell.screens[0] ?? null
    readonly property var active: Events.active(history, now, Notifications.silent, locked || privacyVeil, fullscreen)
    readonly property bool attention: Events.passiveCritical(history, now)
    readonly property string state: locked ? "idle" : opened ? (page === "Apps" ? "launcher" : "expanded") : attention ? "attention" : active ? "glance" : "idle"
    // No trusted event ingress exists until a separately authenticated service is implemented.
    function notify(input) {
        now = Date.now();
        history = Events.insert(history, Events.normalize(input, now, false));
    }
    function toggle() { if (opened) close(); else open("Media"); }
    function open(tab) {
        if (locked) return;
        page = tab;
        selected = active;
        privacyVeil = false;
        opened = true;
    }
    function close() { opened = false; selected = null; }
    function clear() { history = []; selected = null; Notifications.discardAllNotifications(); }
    function dismiss(id) {
        history = Events.remove(history, id);
        if (selected?.id === String(id)) selected = null;
    }
    onLockedChanged: {
        close();
        privacyVeil = true;
    }
    onPrimaryChanged: close()
    Timer {
        interval: 1000; repeat: true; running: root.history.length > 0
        onTriggered: { root.now = Date.now(); root.history = Events.retained(root.history, root.now); }
    }
    Connections {
        target: Notifications
        function onNotify(n) { root.notify({id: "notification:" + n.notificationId, source: n.appName, kind: "notification", title: n.summary, body: n.body, dedupeKey: "notification:" + n.notificationId}); }
        function onDiscard(id) { root.dismiss("notification:" + id); }
        function onDiscardAll() { root.history = root.history.filter(e => e.kind !== "notification"); }
    }
    Connections {
        target: MprisController
        function onTrackChanged() {
            const player = MprisController.activePlayer;
            if (player) root.notify({id: "media", source: "MPRIS", kind: "media", title: player.trackTitle || "Unknown track", body: player.trackArtist || "", dedupeKey: "media"});
        }
    }
    Connections {
        target: Audio
        function onValueChanged() { if (Audio.ready) root.notify({id: "audio", source: "PipeWire", kind: "audio", title: "Volume · " + Math.round(Audio.value * 100) + "%", dedupeKey: "volume"}); }
    }
    Connections {
        target: Brightness
        function onBrightnessChanged() { root.notify({id: "brightness", source: "Display", kind: "brightness", title: "Display brightness changed", dedupeKey: "brightness"}); }
    }
}
