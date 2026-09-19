import QtQuick
import QtQuick.Controls
Slider {
    id: veldoraSlider
    property bool veldoraDanger: false
    from: 0; to: 1
    implicitHeight: VeldoraTokens.sizes.close
    leftPadding: VeldoraTokens.sizes.handle / 2
    rightPadding: leftPadding
    background: Rectangle {
        x: veldoraSlider.leftPadding; y: (veldoraSlider.height - height) / 2
        width: veldoraSlider.availableWidth; height: VeldoraTokens.sizes.track
        radius: VeldoraTokens.radius.pill
        color: VeldoraTokens.colors.surfaceHigh
        Rectangle { width: Math.max(height, parent.width * veldoraSlider.visualPosition); height: parent.height; radius: parent.radius; color: veldoraSlider.veldoraDanger ? VeldoraTokens.colors.danger : VeldoraTokens.colors.accent; visible: veldoraSlider.value > 0 }
    }
    handle: Rectangle {
        x: veldoraSlider.leftPadding + veldoraSlider.visualPosition * veldoraSlider.availableWidth - width / 2
        y: (veldoraSlider.height - height) / 2
        width: VeldoraTokens.sizes.handle; height: width; radius: VeldoraTokens.radius.pill
        color: VeldoraTokens.colors.text
        border.width: veldoraSlider.visualFocus ? 2 : 0
        border.color: VeldoraTokens.colors.accent
    }
}
