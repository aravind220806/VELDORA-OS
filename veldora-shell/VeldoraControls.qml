import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

PanelWindow {
    id: veldoraControls
    property bool veldoraAudioExpanded: false
    visible: VeldoraState.controlsOpen || veldoraCard.opacity > 0
    WlrLayershell.namespace: "veldora-controls"
    WlrLayershell.keyboardFocus: VeldoraState.controlsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors { top: true; right: true }
    margins { top: VeldoraTokens.sizes.bar + VeldoraTokens.spacing.lg; right: VeldoraTokens.spacing.sm }
    implicitWidth: VeldoraTokens.sizes.controlWidth + VeldoraTokens.values.shadow.blur * 2
    implicitHeight: Math.min(screen.height - VeldoraTokens.sizes.bar * 2, veldoraControlColumn.implicitHeight + VeldoraTokens.spacing.sm * 2 + VeldoraTokens.values.shadow.blur * 2)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region { item: veldoraCard }
    VeldoraGlass {
        id: veldoraCard
        anchors.fill: parent; anchors.margins: VeldoraTokens.values.shadow.blur
        radius: VeldoraTokens.radius.card
        opacity: VeldoraState.controlsOpen ? 1 : 0
        scale: VeldoraState.controlsOpen ? 1 : 0.88
        transformOrigin: Item.TopRight
        Behavior on opacity { NumberAnimation { duration: VeldoraTokens.duration } }
        Behavior on scale { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack; easing.overshoot: VeldoraTokens.values.animation.overshoot } }
        focus: VeldoraState.controlsOpen
        Keys.onEscapePressed: VeldoraState.controlsOpen = false
        Image {
            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm
            source: Qt.resolvedUrl("veldora-scales.svg")
            fillMode: Image.Tile
            opacity: VeldoraTokens.values.effects.patternOpacity
        }
        ScrollView {
            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm
            clip: true
            contentWidth: availableWidth
            ColumnLayout {
                id: veldoraControlColumn
                width: parent.width
                spacing: VeldoraTokens.spacing.sm
                Item {
                    Layout.fillWidth: true
                    implicitHeight: VeldoraTokens.sizes.icon
                    Column {
                        anchors.left: parent.left
                        VeldoraText { text: "Your space"; font.pixelSize: VeldoraTokens.font.heading; font.weight: Font.DemiBold }
                        VeldoraText { text: "VELDORA  /  CONTROL CENTER"; font.pixelSize: VeldoraTokens.font.small; color: VeldoraTokens.colors.textDim }
                    }
                    VeldoraButton { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: VeldoraTokens.sizes.close; height: width; veldoraIcon: "close"; veldoraFilled: true; onClicked: VeldoraState.controlsOpen = false; Accessible.name: "Close Control Center" }
                }
                GridLayout {
                    columns: 2; columnSpacing: VeldoraTokens.spacing.sm; rowSpacing: VeldoraTokens.spacing.sm
                    Layout.fillWidth: true
                    VeldoraTile { Layout.fillWidth: true; text: "Wi-Fi"; veldoraIcon: "wifi"; veldoraOn: VeldoraState.hardware.wifi; veldoraSubtitle: veldoraOn ? "On" : "Off"; onClicked: VeldoraState.action(["nmcli", "radio", "wifi", veldoraOn ? "off" : "on"]) }
                    VeldoraTile { Layout.fillWidth: true; text: "Bluetooth"; veldoraIcon: "bluetooth"; veldoraOn: VeldoraState.hardware.bluetooth; veldoraSubtitle: !VeldoraState.hardware.bluetoothAvailable ? "Unavailable" : veldoraOn ? "On" : "Off"; enabled: VeldoraState.hardware.bluetoothAvailable; onClicked: VeldoraState.action(["bluetoothctl", "power", veldoraOn ? "off" : "on"]) }
                    VeldoraTile { Layout.fillWidth: true; text: "Focus"; veldoraIcon: "do_not_disturb_on"; veldoraOn: VeldoraState.focusMode; veldoraSubtitle: veldoraOn ? "Quiet time" : "All notifications"; onClicked: VeldoraState.focusMode = !VeldoraState.focusMode }
                    VeldoraTile { Layout.fillWidth: true; text: "Microphone"; veldoraIcon: VeldoraState.microphone ? "mic" : "mic_off"; veldoraOn: VeldoraState.microphone; veldoraSubtitle: veldoraOn ? "Listening" : "Muted"; enabled: !!VeldoraState.source; onClicked: VeldoraState.source.audio.muted = !VeldoraState.source.audio.muted }
                }
                VeldoraTile { Layout.fillWidth: true; text: "Network"; veldoraIcon: "language"; veldoraSubtitle: VeldoraState.hardware.network; veldoraOn: VeldoraState.hardware.network !== "Disconnected"; onClicked: Quickshell.execDetached(["kitty", "--title", "Veldora Network", "nmtui"]) }
                VeldoraTile { Layout.fillWidth: true; text: "Audio"; veldoraIcon: "speaker"; veldoraSubtitle: VeldoraState.sink ? VeldoraState.sink.description : "No output device"; veldoraOn: !VeldoraState.muted; onClicked: veldoraControls.veldoraAudioExpanded = !veldoraControls.veldoraAudioExpanded }
                ColumnLayout {
                    visible: veldoraControls.veldoraAudioExpanded; Layout.fillWidth: true; spacing: VeldoraTokens.spacing.sm
                    Repeater {
                        model: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
                        delegate: VeldoraTile { required property var modelData; Layout.fillWidth: true; text: modelData.description; veldoraIcon: "speaker"; veldoraOn: modelData === VeldoraState.sink; veldoraSubtitle: veldoraOn ? "Current output" : "Use this output"; onClicked: Pipewire.preferredDefaultAudioSink = modelData }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    VeldoraButton { veldoraIcon: VeldoraState.muted ? "volume_off" : "volume_up"; text: "Sound"; onClicked: { if (VeldoraState.sink) VeldoraState.sink.audio.muted = !VeldoraState.muted; } }
                    Item { Layout.fillWidth: true }
                    VeldoraText { text: Math.round(VeldoraState.volume * 100) + "%" + (VeldoraState.volume > 1 ? "  Boost" : ""); color: VeldoraState.volume > 1 ? VeldoraTokens.colors.danger : VeldoraTokens.colors.textDim }
                }
                VeldoraSlider { Layout.fillWidth: true; enabled: !!VeldoraState.sink; value: Math.min(1, VeldoraState.volume); veldoraDanger: VeldoraState.volume > 1; onMoved: VeldoraState.setVolume(value); Accessible.name: "Sound volume" }
                RowLayout {
                    Layout.fillWidth: true
                    VeldoraIcon { text: "brightness_6" }
                    VeldoraText { text: "Brightness"; Layout.fillWidth: true }
                    VeldoraText { text: VeldoraState.hardware.brightness < 0 ? "Unavailable" : VeldoraState.hardware.brightness + "%"; color: VeldoraTokens.colors.textDim }
                }
                VeldoraSlider {
                    Layout.fillWidth: true; enabled: VeldoraState.hardware.brightness >= 0
                    from: 0.01; value: Math.max(0.01, VeldoraState.hardware.brightness / 100)
                    onMoved: veldoraBrightnessDelay.restart()
                    Timer { id: veldoraBrightnessDelay; interval: 70; onTriggered: VeldoraState.action(["brightnessctl", "set", Math.round(parent.value * 100) + "%"]) }
                    Accessible.name: "Display brightness"
                }
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: veldoraMediaColumn.implicitHeight + VeldoraTokens.spacing.sm * 2
                    radius: VeldoraTokens.radius.tile; color: VeldoraTokens.colors.surfaceHigh
                    ColumnLayout {
                        id: veldoraMediaColumn
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: VeldoraTokens.spacing.sm }
                        spacing: VeldoraTokens.spacing.sm
                        property var veldoraPlayer: Mpris.players.values.length ? Mpris.players.values[0] : null
                        VeldoraText { Layout.fillWidth: true; text: veldoraMediaColumn.veldoraPlayer ? veldoraMediaColumn.veldoraPlayer.trackTitle || "Now playing" : "A little room to breathe"; font.weight: Font.Medium }
                        RowLayout {
                            VeldoraText { Layout.fillWidth: true; text: veldoraMediaColumn.veldoraPlayer ? veldoraMediaColumn.veldoraPlayer.trackArtist : "No media playing"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
                            VeldoraButton { veldoraIcon: "skip_previous"; enabled: !!veldoraMediaColumn.veldoraPlayer && veldoraMediaColumn.veldoraPlayer.canTogglePlaying; onClicked: veldoraMediaColumn.veldoraPlayer.previous() }
                            VeldoraButton { veldoraIcon: veldoraMediaColumn.veldoraPlayer && veldoraMediaColumn.veldoraPlayer.isPlaying ? "pause" : "play_arrow"; enabled: !!veldoraMediaColumn.veldoraPlayer && veldoraMediaColumn.veldoraPlayer.canTogglePlaying; onClicked: veldoraMediaColumn.veldoraPlayer.togglePlaying() }
                            VeldoraButton { veldoraIcon: "skip_next"; enabled: !!veldoraMediaColumn.veldoraPlayer && veldoraMediaColumn.veldoraPlayer.canTogglePlaying; onClicked: veldoraMediaColumn.veldoraPlayer.next() }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: VeldoraTokens.spacing.sm
                    VeldoraButton { Layout.fillWidth: true; veldoraFilled: true; veldoraIcon: "lock"; text: "Lock"; onClicked: { VeldoraState.controlsOpen = false; Quickshell.execDetached(["veldora-shell", "--lock"]); } }
                    VeldoraButton { Layout.fillWidth: true; veldoraFilled: true; veldoraIcon: "music_note"; text: "Media"; onClicked: { if (veldoraMediaColumn.veldoraPlayer) veldoraMediaColumn.veldoraPlayer.raise(); } }
                    VeldoraButton { Layout.fillWidth: true; veldoraFilled: true; veldoraIcon: "power_settings_new"; text: "Power"; veldoraTint: VeldoraTokens.colors.accent; onClicked: VeldoraState.powerOpen = !VeldoraState.powerOpen }
                }
                ColumnLayout {
                    visible: VeldoraState.powerOpen
                    Layout.fillWidth: true; spacing: VeldoraTokens.spacing.sm
                    VeldoraText { text: "End this session"; color: VeldoraTokens.colors.textDim }
                    RowLayout {
                        VeldoraButton { text: "Sleep"; veldoraIcon: "bedtime"; onClicked: { VeldoraState.controlsOpen = false; Quickshell.execDetached(["systemctl", "suspend"]); } }
                        VeldoraButton { text: "Restart"; veldoraIcon: "restart_alt"; onClicked: veldoraPowerDialog.veldoraCommand = "reboot" }
                        VeldoraButton { text: "Shut down"; veldoraIcon: "power_settings_new"; onClicked: veldoraPowerDialog.veldoraCommand = "poweroff" }
                    }
                    VeldoraButton {
                        id: veldoraPowerDialog
                        property string veldoraCommand: ""
                        visible: veldoraCommand !== ""
                        text: "Confirm " + (veldoraCommand === "reboot" ? "restart" : "shutdown")
                        veldoraTint: VeldoraTokens.colors.danger
                        onClicked: Quickshell.execDetached(["systemctl", veldoraCommand])
                    }
                }
            }
        }
    }
}
