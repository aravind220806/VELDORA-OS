pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Wayland
import "VeldoraEvents.js" as VeldoraEvents
import "VeldoraApps.js" as VeldoraApps

Singleton {
    id: veldoraState
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["openwindow","closewindow","windowtitle","windowtitlev2","movewindow","movewindowv2"].includes(event.name)) veldoraWindowRefresh.restart();
        }
    }
    Timer { id: veldoraWindowRefresh; interval: 60; running: true; onTriggered: Hyprland.refreshToplevels() }
    property bool overviewOpen: false
    property bool islandOpen: false
    property bool privacyMode: false
    property bool privacyVeil: false
    property string islandPage: "Media"
    property var history: []
    property double eventTime: Date.now()
    readonly property bool fullscreen: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.fullscreen : false
    readonly property var activeEvent: VeldoraEvents.veldoraActive(history, eventTime, focusMode, privacyMode || privacyVeil, fullscreen)
    readonly property string islandState: privacyMode ? "idle" : islandOpen ? (islandPage === "Apps" ? "launcher" : "expanded") : activeEvent ? "glance" : "idle"
    readonly property var player: Mpris.players.values.length ? Mpris.players.values[0] : null
    readonly property string mediaTitle: player ? player.trackTitle : ""
    readonly property var dockApps: VeldoraApps.veldoraGroup(applications, settings.pinnedApps, Hyprland.toplevels.values)
    readonly property bool reducedMotion: settings.reducedMotion === true
    function closePanels() { overviewOpen = false; launcherOpen = false; controlsOpen = false; islandOpen = false; }
    function toggleOverview() { const veldoraOpen = !overviewOpen; closePanels(); overviewOpen = veldoraOpen && !privacyMode; }
    function toggleIsland() { const veldoraOpen = !islandOpen; closePanels(); islandOpen = veldoraOpen && !privacyMode; privacyVeil = false; }
    function recordEvent(veldoraInput) { if (privacyMode) return; eventTime = Date.now(); history = VeldoraEvents.veldoraInsert(history, VeldoraEvents.veldoraNormalize(veldoraInput, eventTime)); }
    function dismissEvent(veldoraId) { history = VeldoraEvents.veldoraRemove(history, veldoraId); }
    function setPrivacy(veldoraValue) { privacyMode = veldoraValue; privacyVeil = true; closePanels(); history = []; osdKind = ""; }
    function dockActivate(veldoraId) {
        const veldoraApp = dockApps.find(a => a.id === veldoraId);
        if (!veldoraApp) return;
        if (!veldoraApp.windows.length) { if (veldoraApp.entry) veldoraApp.entry.execute(); }
        else { const veldoraIndex = veldoraApp.windows.findIndex(w => w.activated); activateWindow(veldoraApp.windows[(veldoraIndex+1)%veldoraApp.windows.length].address); }
    }
    property bool controlsOpen: false
    property bool launcherOpen: false
    property bool powerOpen: false
    property bool focusMode: false
    property bool dockPinned: settings.dockPinned !== false
    function setPreference(veldoraKey, veldoraValue) { const veldoraNext = Object.assign({},settings); veldoraNext[veldoraKey] = veldoraValue; settings = veldoraNext; veldoraSettingsFile.setText(JSON.stringify(veldoraNext,null,2)); }
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
    function toggleLauncher() { const veldoraOpen = !launcherOpen; closePanels(); launcherOpen = veldoraOpen && !privacyMode; }
    function toggleControls() { const veldoraOpen = !controlsOpen; closePanels(); controlsOpen = veldoraOpen && !privacyMode; powerOpen = false; }
    function showOsd(veldoraKind) {
        recordEvent({id:veldoraKind,kind:veldoraKind === "volume" ? "audio" : veldoraKind,source:"Veldora",title:veldoraKind === "volume" ? "Volume · " + Math.round(volume*100) + "%" : "Brightness · " + hardware.brightness + "%",dedupeKey:veldoraKind});
        if (!privacyMode && !fullscreen) { osdKind = veldoraKind; veldoraOsdTimer.restart(); }
    }
    function setVolume(veldoraValue) { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, veldoraValue)); }
    function activateWorkspace(veldoraId) { action(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus({workspace=" + JSON.stringify(String(veldoraId)) + "}))"]); }
    function activateWindow(veldoraAddress) { action(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus({window=" + JSON.stringify("address:0x" + veldoraAddress.replace(/^0x/, "")) + "}))"]); }
    property var veldoraActionQueue: []
    function action(veldoraCommand) { veldoraActionQueue = veldoraActionQueue.concat([veldoraCommand]); runNextAction(); }
    function runNextAction() {
        if (veldoraAction.running || !veldoraActionQueue.length) return;
        veldoraAction.command = veldoraActionQueue[0];
        veldoraActionQueue = veldoraActionQueue.slice(1);
        veldoraAction.running = true;
    }
    function findApp(veldoraClass) { return VeldoraApps.veldoraFind(applications, veldoraClass); }
    onMediaTitleChanged: { if (mediaTitle) recordEvent({id:"media",source:"MPRIS",kind:"media",title:mediaTitle,body:player.trackArtist}); }
    onFullscreenChanged: { if (fullscreen) { osdKind = ""; closePanels(); } }
    Timer { interval: 500; running: veldoraState.history.length > 0; repeat: true; onTriggered: { veldoraState.eventTime = Date.now(); veldoraState.history = VeldoraEvents.veldoraRetained(veldoraState.history, veldoraState.eventTime); } }
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
        running: Quickshell.env("VELDORA_ISOLATED") !== "1"
        stdout: SplitParser { onRead: veldoraLine => { try { veldoraState.hardware = JSON.parse(veldoraLine); } catch (veldoraError) { console.warn("Veldora hardware:", veldoraError); } } }
    }
    Process {
        id: veldoraAction
        stderr: StdioCollector { id: veldoraActionError }
        onExited: (veldoraCode, veldoraStatus) => {
            Qt.callLater(veldoraState.runNextAction);
            if (veldoraCode !== 0) Quickshell.execDetached(["notify-send", "Veldora", veldoraActionError.text || "The device did not accept this change."]);
        }
    }
}
