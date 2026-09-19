import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: veldoraOsd
    visible: VeldoraState.osdKind !== ""
    WlrLayershell.namespace: "veldora-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors.bottom: true
    margins.bottom: VeldoraTokens.sizes.dockHeight + VeldoraTokens.sizes.dockGap
    implicitWidth: VeldoraTokens.sizes.osdWidth + VeldoraTokens.values.shadow.blur * 2
    implicitHeight: VeldoraTokens.sizes.iconHover + VeldoraTokens.values.shadow.blur * 2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region { item: veldoraOsdGlass }
    VeldoraGlass {
        id: veldoraOsdGlass
        anchors.fill: parent; anchors.margins: VeldoraTokens.values.shadow.blur
        RowLayout {
            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm; spacing: VeldoraTokens.spacing.sm
            VeldoraIcon { text: VeldoraState.osdKind === "brightness" ? "brightness_6" : VeldoraState.muted ? "volume_off" : "volume_up"; color: VeldoraTokens.colors.accent }
            VeldoraSlider {
                Layout.fillWidth: true
                value: VeldoraState.osdKind === "brightness" ? VeldoraState.hardware.brightness / 100 : Math.min(1, VeldoraState.volume)
                veldoraDanger: VeldoraState.osdKind === "volume" && VeldoraState.volume > 1
                onMoved: {
                    if (VeldoraState.osdKind === "volume") VeldoraState.setVolume(value);
                    else VeldoraState.action(["brightnessctl", "set", Math.max(1, Math.round(value * 100)) + "%"]);
                    VeldoraState.showOsd(VeldoraState.osdKind);
                }
                Accessible.name: VeldoraState.osdKind
            }
            VeldoraText { text: VeldoraState.osdKind === "brightness" ? VeldoraState.hardware.brightness + "%" : Math.round(VeldoraState.volume * 100) + "%" + (VeldoraState.volume > 1 ? " Boost" : ""); font.pixelSize: VeldoraTokens.font.small }
        }
    }
}
