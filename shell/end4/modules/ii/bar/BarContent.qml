// SPDX-License-Identifier: GPL-3.0-or-later
// Veldora composition, 2026-09-14. Pinned upstream services, original layout.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import qs
import qs.services
import qs.modules.veldora.theme
import qs.modules.veldora.veldock
Item {
    id: root
    property var screen: QsWindow.window?.screen
    readonly property var monitor: Hyprland.monitors.values.find(m => m.name === screen?.name)
    readonly property int workspace: monitor?.activeWorkspace?.id ?? 1
    readonly property bool primary: screen === DockState.primary
    readonly property var workspaces: Quickshell.env("VELDORA_ALL_WORKSPACES") === "1" ? [1,2,3,4,5,6,7,8,9,10] : [...new Set([workspace, ...Hyprland.workspaces.values.filter(w => w.id > 0 && w.toplevels.values.length > 0).map(w => w.id)])].sort((a,b) => a-b)
    RowLayout {
        id: left
        anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Repeater {
            model: root.workspaces.slice(0, root.width < 1000 ? 3 : 10)
            Action {
                required property int modelData
                implicitWidth: 30; implicitHeight: 30
                text: String(modelData); checked: root.workspace === modelData
                Accessible.name: "Workspace " + modelData
                onClicked: Hyprland.dispatch("hl.dsp.focus({workspace = " + modelData + "})")
            }
        }
    }
    VeldoraIsland {
        visible: root.primary && !DockState.fullscreen
        anchors.centerIn: parent
        maximumWidth: Math.max(80, Math.min(380, root.width - 2 * Math.max(left.width, right.width) - 32))
    }
    RowLayout {
        id: right
        anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Action {
            visible: root.width > 1050
            text: Network.ethernet ? "Ethernet" : Network.wifiStatus === "connected" ? "Wi-Fi" : "Wi-Fi · " + Network.wifiStatus
            implicitHeight: 30
            Accessible.name: "Network: " + text
            onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
        }
        Action {
            visible: root.width > 1500
            text: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? "BT on" : "BT off") : "No BT"
            implicitHeight: 30
            onClicked: Quickshell.execDetached(["blueman-manager"])
        }
        Action {
            text: Audio.ready ? (Audio.sink.audio.muted ? "Muted" : Math.round(Audio.value * 100) + "%") : "No audio"
            implicitHeight: 30
            onClicked: DockState.open("Audio")
        }
        Action {
            visible: root.width > 700
            text: Battery.available ? Math.round(Battery.percentage * 100) + "% battery" : "Power"
            implicitHeight: 30
            onClicked: GlobalStates.sessionOpen = !GlobalStates.sessionOpen
        }
        Action { text: "⋮"; Accessible.name: "Control center"; implicitHeight: 30; onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen }
    }
}
