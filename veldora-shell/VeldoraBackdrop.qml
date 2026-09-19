import QtQuick
import Quickshell
import Quickshell.Wayland
PanelWindow {
    WlrLayershell.namespace: "veldora-backdrop"
    WlrLayershell.layer: WlrLayer.Background
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: VeldoraTokens.colors.background
    mask: Region {}
    Image { anchors.fill: parent; source: "file://" + VeldoraState.settings.wallpaper; fillMode: Image.PreserveAspectCrop; asynchronous: true }
}
