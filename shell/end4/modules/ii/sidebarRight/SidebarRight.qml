// SPDX-License-Identifier: GPL-3.0-or-later
// Veldora control center, 2026-09-14. Uses end-4 services.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
Scope {
    PanelWindow {
        id: panel
        visible: GlobalStates.sidebarRightOpen && !GlobalStates.screenLocked
        anchors { top: true; right: true }
        margins { top: 46; right: 14 }
        implicitWidth: 370
        implicitHeight: 590
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "veldora-control-center"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        property var monitor: Brightness.getMonitorForScreen(screen)
        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "#f21a1a1e"
            border.color: "#48484e"
            focus: true
            Keys.onEscapePressed: GlobalStates.sidebarRightOpen = false
            component SmallButton: Button {
                id: small
                background: Rectangle { radius: 10; color: small.down ? "#494950" : "#303036"; border.color: small.activeFocus ? "#ff8792" : "#49494f" }
                contentItem: Text { text: small.text; color: "#ededf2"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12 }
                implicitHeight: 34
            }
            component Tile: Button {
                id: tile
                property string symbol
                property string subtitle
                property bool active: false
                Layout.fillWidth: true
                implicitHeight: 76
                background: Rectangle { radius: 16; color: tile.down ? "#45454e" : tile.active ? "#493035" : "#2b2b30"; border.color: tile.activeFocus ? "#ff8792" : "#424247" }
                contentItem: RowLayout {
                    spacing: 10
                    MaterialSymbol { text: tile.symbol; iconSize: 24; color: tile.active ? "#ff8792" : "#ededf2" }
                    ColumnLayout {
                        Text { text: tile.text; color: "#fafafa"; font.pixelSize: 13 }
                        Text { text: tile.subtitle; color: "#b9b9c3"; font.pixelSize: 11 }
                    }
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                RowLayout {
                    Text { text: "Control Center"; color: "#ffffff"; font.pixelSize: 21; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    SmallButton { implicitWidth: 34; text: "×"; Accessible.name: "Close control center"; onClicked: GlobalStates.sidebarRightOpen = false }
                }
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 10; rowSpacing: 10
                    Tile { text: "Wi-Fi"; symbol: "wifi"; subtitle: Network.wifiEnabled ? "Enabled" : "Off"; active: Network.wifiEnabled; onClicked: Network.toggleWifi() }
                    Tile { text: "Bluetooth"; symbol: "bluetooth"; subtitle: "Devices & pairing"; onClicked: Quickshell.execDetached(["blueman-manager"]) }
                    Tile { text: "Focus"; symbol: "do_not_disturb_on"; subtitle: Notifications.silent ? "Do not disturb" : "Notifications on"; active: Notifications.silent; onClicked: Notifications.silent = !Notifications.silent }
                    Tile { text: "Microphone"; symbol: "mic"; subtitle: !Audio.source ? "Unavailable" : Audio.source.audio.muted ? "Muted" : "Live"; active: Audio.source?.audio.muted ?? false; enabled: !!Audio.source; onClicked: Audio.toggleMicMute() }
                }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 84; radius: 16; color: "#2b2b30"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 2
                        Text { text: "Sound  ·  " + (Audio.ready ? Math.round(Audio.value * 100) + "%" : "No output"); color: "#eeeeef"; font.pixelSize: 13 }
                        Slider { Layout.fillWidth: true; from: 0; to: 1; value: Audio.value; enabled: Audio.ready; onMoved: Audio.sink.audio.volume = value; Accessible.name: "Output volume" }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 84; radius: 16; color: "#2b2b30"
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 2
                        Text { text: "Display brightness"; color: "#eeeeef"; font.pixelSize: 13 }
                        Slider { Layout.fillWidth: true; from: 0.05; to: 1; value: panel.monitor?.brightness ?? 1; enabled: panel.monitor?.ready ?? false; onMoved: panel.monitor.setBrightness(value); Accessible.name: "Display brightness" }
                    }
                }
                RowLayout {
                    Tile { text: "Network"; subtitle: "Connections / VPN"; symbol: "lan"; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
                    Tile { text: "Audio"; subtitle: "Inputs & outputs"; symbol: "volume_up"; onClicked: Quickshell.execDetached(["pavucontrol"]) }
                }
                RowLayout {
                    SmallButton { text: "Lock"; Layout.fillWidth: true; onClicked: { GlobalStates.sidebarRightOpen = false; Quickshell.execDetached(["hyprlock"]); } }
                    SmallButton { text: "Media"; Layout.fillWidth: true; onClicked: { GlobalStates.sidebarRightOpen = false; GlobalStates.mediaControlsOpen = true; } }
                    SmallButton { text: "Power…"; Layout.fillWidth: true; onClicked: { GlobalStates.sidebarRightOpen = false; GlobalStates.sessionOpen = true; } }
                }
            }
        }
    }
    IpcHandler {
        target: "sidebarRight"
        function toggle(): void { GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen; }
        function open(): void { GlobalStates.sidebarRightOpen = true; }
        function close(): void { GlobalStates.sidebarRightOpen = false; }
    }
}
