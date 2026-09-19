pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

Singleton {
    id: veldoraState
    property bool controlsOpen: false
    property bool launcherOpen: false
    property bool powerOpen: false
    property bool focusMode: false
    property bool dockPinned: true
    property string osdKind: ""
    property var hardware: ({wifi:false, network:"Checking…", bluetooth:false, bluetoothAvailable:false, brightness:-1, battery:-1, charging:false})
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : true
    readonly property bool microphone: source && source.audio ? !source.audio.muted : false
    readonly property var applications: DesktopEntries.applications.values.filter(veldoraApp => !veldoraApp.noDisplay).sort((a,b) => a.name.localeCompare(b.name))
    property var settings: JSON.parse(veldoraSettingsFile.text())
    property bool veldoraAudioReady: false
    property bool veldoraHardwareReady: false
    function toggleLauncher() { launcherOpen = !launcherOpen; controlsOpen = false; }
    function toggleControls() { controlsOpen = !controlsOpen; launcherOpen = false; powerOpen = false; }
    function showOsd(veldoraKind) { osdKind = veldoraKind; veldoraOsdTimer.restart(); }
    function setVolume(veldoraValue) { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, veldoraValue)); }
    function activateWorkspace(veldoraId) { action(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus({workspace=" + JSON.stringify(String(veldoraId)) + "}))"]); }
    function activateWindow(veldoraAddress) { action(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus({window=" + JSON.stringify("address:0x" + veldoraAddress.replace(/^0x/, "")) + "}))"]); }
    function action(veldoraCommand) { veldoraAction.command = veldoraCommand; veldoraAction.running = true; }
    function findApp(veldoraClass) {
        const veldoraLower = veldoraClass.toLowerCase();
        return applications.find(a => a.id.toLowerCase() === veldoraLower || a.startupClass.toLowerCase() === veldoraLower || a.id.toLowerCase().split('.').pop() === veldoraLower);
    }
    onVolumeChanged: { if (veldoraAudioReady) showOsd("volume"); }
    onMutedChanged: { if (veldoraAudioReady) showOsd("volume"); }
    onHardwareChanged: {
        if (veldoraHardwareReady && veldoraLastBrightness >= 0 && hardware.brightness !== veldoraLastBrightness) showOsd("brightness");
        veldoraLastBrightness = hardware.brightness;
        veldoraHardwareReady = true;
    }
    property int veldoraLastBrightness: -1
    PwObjectTracker { objects: [veldoraState.sink, veldoraState.source] }
    Timer { interval: 1800; running: true; onTriggered: veldoraState.veldoraAudioReady = true }
    Timer { id: veldoraOsdTimer; interval: VeldoraTokens.values.timing.osd; onTriggered: veldoraState.osdKind = "" }
    FileView { id: veldoraSettingsFile; path: Qt.resolvedUrl("veldora-settings.json"); blockLoading: true }
    Process {
        id: veldoraHardware
        command: ["python3", Qt.resolvedUrl("veldora-hardware.py").toString().replace("file://", ""), "watch"]
        running: true
        stdout: SplitParser { onRead: veldoraLine => { try { veldoraState.hardware = JSON.parse(veldoraLine); } catch (veldoraError) { console.warn("Veldora hardware:", veldoraError); } } }
    }
    Process {
        id: veldoraAction
        stderr: StdioCollector { id: veldoraActionError }
        onExited: (veldoraCode, veldoraStatus) => {
            if (veldoraCode !== 0) Quickshell.execDetached(["notify-send", "Veldora", veldoraActionError.text || "The device did not accept this change."]);
        }
    }
}
