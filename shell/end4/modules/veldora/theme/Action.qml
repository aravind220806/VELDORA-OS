// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
Button {
    id: root
    implicitHeight: 36
    padding: 8
    Accessible.name: text
    background: Rectangle { radius: 10; color: root.down || root.checked ? Storm.accent : Storm.raised; border.width: root.activeFocus ? 2 : 1; border.color: root.activeFocus ? Storm.accent : Storm.border }
    contentItem: Text { text: root.text; textFormat: Text.PlainText; font.family: Storm.font; font.pixelSize: 13; color: !root.enabled ? Storm.secondary : root.down || root.checked ? Storm.canvas : Storm.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
}
