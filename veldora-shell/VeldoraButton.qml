import QtQuick
import QtQuick.Controls
Button {
    id: veldoraButton
    property string veldoraIcon: ""
    property bool veldoraSelected: false
    property bool veldoraFilled: false
    property color veldoraTint: VeldoraTokens.colors.text
    implicitHeight: VeldoraTokens.sizes.close
    implicitWidth: Math.max(implicitHeight, veldoraContent.implicitWidth + VeldoraTokens.spacing.sm * 2)
    hoverEnabled: true
    padding: VeldoraTokens.spacing.sm
    Accessible.name: text || veldoraIcon
    background: Rectangle {
        radius: VeldoraTokens.radius.pill
        color: veldoraButton.hovered || veldoraButton.veldoraSelected ? VeldoraTokens.accentSoft : veldoraButton.veldoraFilled ? VeldoraTokens.colors.surfaceHigh : "transparent"
        border.width: veldoraButton.visualFocus ? 1 : 0
        border.color: VeldoraTokens.colors.accent
        Behavior on color { ColorAnimation { duration: VeldoraTokens.duration } }
    }
    contentItem: Item {
        implicitWidth: veldoraContent.implicitWidth
        implicitHeight: veldoraContent.implicitHeight
        Row {
            id: veldoraContent
            spacing: VeldoraTokens.spacing.xs
            anchors.centerIn: parent
            VeldoraIcon { visible: text !== ""; text: veldoraButton.veldoraIcon; color: veldoraButton.veldoraTint; anchors.verticalCenter: parent.verticalCenter }
            VeldoraText { visible: text !== ""; text: veldoraButton.text; color: veldoraButton.veldoraTint; anchors.verticalCenter: parent.verticalCenter }
        }
    }
}
