// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
Rectangle {
    id: root
    property string eventTitle: ""
    property string eventBody: ""
    property string eventIcon: "notifications"
    property bool eventActive: false
    property bool detailOpen: false
    readonly property var player: MprisController.activePlayer
    width: eventActive ? Math.min(420, Math.max(230, title.implicitWidth + 65)) : title.implicitWidth + 26
    height: 30
    radius: height / 2
    color: Qt.rgba(0.10, 0.09, 0.13, 0.95)
    border.width: 1
    border.color: Qt.rgba(0.85, 0.80, 0.95, 0.12)
    Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
    function present(title, body, icon) {
        eventTitle = String(title).slice(0, 160);
        eventBody = String(body ?? "").slice(0, 400);
        eventIcon = icon;
        eventActive = true;
        dismiss.restart();
    }
    Timer { id: dismiss; interval: 5000; onTriggered: { root.eventActive = false; root.detailOpen = false; } }
    StyledText {
        id: title
        anchors.centerIn: parent
        width: Math.min(implicitWidth, 345)
        text: root.eventActive ? root.eventTitle : DateTime.shortDate + " · " + DateTime.time
        textFormat: Text.PlainText
        elide: Text.ElideRight
        font.pixelSize: 13
        font.weight: Font.Medium
        color: "#e5dfee"
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
            else GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
        }
    }
    Connections {
        target: Notifications
        function onNotify(notification) {
            if (!Notifications.silent) root.present(notification.summary, notification.body, "notifications");
        }
    }
    Connections {
        target: MprisController
        function onTrackChanged() {
            if (root.player?.trackTitle) root.present(root.player.trackTitle, root.player.trackArtist, "music_note");
        }
    }
    Connections {
        target: GlobalStates
        function onOsdVolumeOpenChanged() { if (GlobalStates.osdVolumeOpen) root.present("Volume · " + Math.round(Audio.value * 100) + "%", "", "volume_up"); }
        function onOsdBrightnessOpenChanged() { if (GlobalStates.osdBrightnessOpen) root.present("Brightness updated", "", "brightness_6"); }
    }
    Connections {
        target: Audio
        function onValueChanged() { if (GlobalStates.osdVolumeOpen) root.present("Volume · " + Math.round(Audio.value * 100) + "%", "", "volume_up"); }
    }
}
