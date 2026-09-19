// SPDX-License-Identifier: GPL-3.0-or-later
// Compatibility surface for the Veldora VelDock controller, 2026-09-14.
import QtQuick
import QtQuick.Controls
import qs.services
import qs.modules.veldora.theme
import qs.modules.veldora.veldock
Button {
    id: root
    property real maximumWidth: 380
    implicitWidth: Math.min(maximumWidth, DockState.active ? 340 : 200)
    implicitHeight: 34
    Accessible.name: "Toggle VelDock"
    hoverEnabled: true
    ToolTip.visible: hovered
    ToolTip.text: "VelDock · Super + I"
    onClicked: DockState.toggle()
    background: Rectangle { radius: DockState.opened ? 12 : 17; color: Storm.surface; border.width: root.activeFocus ? 2 : 1; border.color: root.activeFocus || DockState.opened ? Storm.accent : Storm.border }
    contentItem: Text {
        text: DockState.privacyVeil ? "VelDock · " + DockState.history.length + " events" : DockState.active ? DockState.active.title : "◈  " + DateTime.time
        textFormat: Text.PlainText
        font.family: Storm.font; font.pixelSize: 13
        color: Storm.text; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }
    Behavior on implicitWidth { NumberAnimation { duration: Storm.duration; easing.type: Easing.OutCubic } }
}
