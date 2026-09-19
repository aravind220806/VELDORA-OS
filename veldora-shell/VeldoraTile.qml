import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Button {
    id: veldoraTile
    property string veldoraIcon: ""
    property string veldoraSubtitle: ""
    property bool veldoraOn: false
    implicitHeight: VeldoraTokens.sizes.icon + VeldoraTokens.spacing.sm * 2
    hoverEnabled: true
    Accessible.name: text + ", " + veldoraSubtitle
    background: Rectangle {
        radius: VeldoraTokens.radius.tile
        color: veldoraTile.veldoraOn || veldoraTile.hovered ? VeldoraTokens.accentSoft : VeldoraTokens.colors.surfaceHigh
        border.width: veldoraTile.visualFocus ? 1 : 0
        border.color: VeldoraTokens.colors.accent
        Behavior on color { ColorAnimation { duration: VeldoraTokens.duration } }
    }
    contentItem: RowLayout {
        spacing: VeldoraTokens.spacing.sm
        Rectangle {
            Layout.preferredWidth: VeldoraTokens.sizes.close; Layout.preferredHeight: width
            radius: VeldoraTokens.radius.pill
            color: veldoraTile.veldoraOn ? VeldoraTokens.accentSoft : VeldoraTokens.surface
            VeldoraIcon { anchors.centerIn: parent; text: veldoraTile.veldoraIcon; color: veldoraTile.veldoraOn ? VeldoraTokens.colors.accent : VeldoraTokens.colors.textDim }
        }
        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            VeldoraText { Layout.fillWidth: true; text: veldoraTile.text; font.weight: Font.Medium }
            VeldoraText { Layout.fillWidth: true; text: veldoraTile.veldoraSubtitle; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
        }
    }
    padding: VeldoraTokens.spacing.sm
}
