import QtQuick
import QtQuick.Effects
Rectangle {
    id: veldoraGlass
    color: VeldoraTokens.surface
    radius: VeldoraTokens.radius.pill
    border.width: 1
    border.color: VeldoraTokens.border
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 1
        blurMax: VeldoraTokens.values.shadow.blur
        shadowVerticalOffset: VeldoraTokens.values.shadow.offsetY
        shadowColor: VeldoraTokens.alpha(VeldoraTokens.values.shadow.color, VeldoraTokens.values.shadow.opacity)
    }
}
