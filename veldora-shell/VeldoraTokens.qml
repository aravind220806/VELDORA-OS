pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: veldoraTokens
    readonly property var values: JSON.parse(veldoraFile.text())
    readonly property var colors: values.colors
    readonly property var radius: values.radius
    readonly property var spacing: values.spacing
    readonly property var sizes: values.sizes
    readonly property var font: values.font
    readonly property int duration: VeldoraState.reducedMotion ? 0 : values.animation.duration
    readonly property color surface: alpha(colors.surface, colors.surfaceOpacity)
    readonly property color accentSoft: alpha(colors.accent, colors.accentOpacity)
    readonly property color border: alpha(colors.border, colors.borderOpacity)
    function alpha(veldoraColor, veldoraOpacity) { return Qt.alpha(veldoraColor, veldoraOpacity); }
    FileView {
        id: veldoraFile
        path: Qt.resolvedUrl("veldora-tokens.json")
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
