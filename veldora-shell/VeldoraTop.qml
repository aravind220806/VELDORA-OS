import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: veldoraTop
    WlrLayershell.namespace: "veldora-top"
    anchors { top: true; left: true; right: true }
    implicitHeight: VeldoraTokens.sizes.bar + VeldoraTokens.sizes.barGap + VeldoraTokens.values.shadow.blur
    exclusiveZone: VeldoraTokens.sizes.bar + VeldoraTokens.sizes.barGap * 2
    color: "transparent"
    mask: Region {
        item: veldoraLeft
        Region { item: veldoraClockPill }
        Region { item: veldoraRight }
    }
    SystemClock { id: veldoraClock; precision: SystemClock.Minutes }
    VeldoraGlass {
        id: veldoraLeft
        x: VeldoraTokens.sizes.barGap; y: VeldoraTokens.sizes.barGap
        width: veldoraWorkspaces.width + VeldoraTokens.spacing.sm * 2
        height: VeldoraTokens.sizes.bar
        Row {
            id: veldoraWorkspaces
            anchors.centerIn: parent
            spacing: VeldoraTokens.spacing.sm
            VeldoraButton { text: "VELDORA"; veldoraTint: VeldoraTokens.colors.accent; onClicked: VeldoraState.toggleOverview() }
            Repeater {
                model: Hyprland.workspaces
                delegate: Item {
                    id: veldoraWorkspace
                    required property var modelData
                    readonly property bool veldoraActive: Hyprland.focusedWorkspace === modelData
                    visible: modelData.id > 0 && (veldoraActive || modelData.toplevels.values.length > 0)
                    width: visible ? (veldoraActive ? VeldoraTokens.sizes.icon : VeldoraTokens.spacing.sm) : 0
                    height: VeldoraTokens.sizes.close
                    Behavior on width { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack; easing.overshoot: VeldoraTokens.values.animation.overshoot } }
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width; height: veldoraWorkspace.veldoraActive ? VeldoraTokens.radius.card : VeldoraTokens.spacing.sm
                        radius: VeldoraTokens.radius.pill
                        color: veldoraWorkspace.veldoraActive ? VeldoraTokens.colors.accent : (veldoraWorkspaceMouse.containsMouse ? VeldoraTokens.accentSoft : VeldoraTokens.colors.textDim)
                        layer.enabled: veldoraWorkspace.veldoraActive
                        layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1; blurMax: VeldoraTokens.values.shadow.blur; shadowColor: VeldoraTokens.alpha(VeldoraTokens.colors.accent, VeldoraTokens.values.effects.workspaceGlow) }
                        VeldoraText { anchors.centerIn: parent; visible: veldoraWorkspace.veldoraActive; text: veldoraWorkspace.modelData.name; color: VeldoraTokens.colors.background; font.bold: true }
                    }
                    MouseArea { id: veldoraWorkspaceMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: VeldoraState.activateWorkspace(veldoraWorkspace.modelData.id) }
                }
            }
        }
    }
    VeldoraGlass {
        id: veldoraClockPill
        anchors.horizontalCenter: parent.horizontalCenter
        y: VeldoraTokens.sizes.barGap
        Behavior on width { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack } }
        property real veldoraAvailable: Math.max(100, veldoraTop.width - 2*Math.max(veldoraLeft.width,veldoraRight.width) - VeldoraTokens.spacing.lg*2)
        width: Math.min(veldoraAvailable, (VeldoraState.activeEvent ? 330 : 220)); height: VeldoraTokens.sizes.bar
        Rectangle { anchors.fill: parent; radius: parent.radius; color: VeldoraTokens.accentSoft; visible: veldoraClockMouse.containsMouse }
        VeldoraText { id: veldoraTime; anchors.centerIn: parent; width: parent.width - VeldoraTokens.spacing.lg*2; horizontalAlignment: Text.AlignHCenter; text: VeldoraState.privacyVeil ? "VelDock · " + VeldoraState.history.length + " events" : VeldoraState.activeEvent ? VeldoraState.activeEvent.title : Qt.formatDateTime(veldoraClock.date, "hh:mm  ·  ddd, dd MMM"); font.weight: Font.Medium }
        MouseArea { id: veldoraClockMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: VeldoraState.toggleIsland() }
    }
    VeldoraGlass {
        id: veldoraRight
        anchors.right: parent.right; anchors.rightMargin: VeldoraTokens.sizes.barGap
        y: VeldoraTokens.sizes.barGap
        width: veldoraStatus.width + VeldoraTokens.spacing.sm * 2; height: VeldoraTokens.sizes.bar
        Row {
            id: veldoraStatus; anchors.centerIn: parent
            VeldoraButton { veldoraIcon: VeldoraState.muted ? "volume_off" : "volume_up"; text: Math.round(VeldoraState.volume * 100) + "%"; onClicked: VeldoraState.toggleControls(); Accessible.name: "Sound and controls" }
            VeldoraButton { veldoraIcon: VeldoraState.hardware.wifi ? "wifi" : "wifi_off"; onClicked: VeldoraState.toggleControls(); Accessible.name: "Wi-Fi controls" }
            VeldoraButton { veldoraIcon: VeldoraState.hardware.bluetooth ? "bluetooth_connected" : "bluetooth_disabled"; onClicked: VeldoraState.toggleControls(); Accessible.name: "Bluetooth controls" }
            VeldoraButton { visible: VeldoraState.hardware.battery >= 0; veldoraIcon: VeldoraState.hardware.charging ? "battery_charging_full" : "battery_horiz_075"; text: VeldoraState.hardware.battery + "%"; onClicked: VeldoraState.toggleControls() }
            VeldoraButton { veldoraIcon: "power_settings_new"; veldoraTint: VeldoraTokens.colors.accent; onClicked: { VeldoraState.closePanels(); VeldoraState.controlsOpen = !VeldoraState.privacyMode; VeldoraState.powerOpen = true; } Accessible.name: "Power menu" }
        }
    }
}
