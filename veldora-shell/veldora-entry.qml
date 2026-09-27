import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    VeldoraControls {}
    VeldoraOverview {}
    VeldoraIsland {}
    VeldoraLauncher {}
    Variants {
        model: Quickshell.env("VELDORA_PREVIEW") === "1" ? [] : Quickshell.screens
        delegate: VeldoraBackdrop { required property var modelData; screen: modelData }
    }
    VeldoraOsd {}
    LazyLoader { active: Quickshell.env("VELDORA_PREVIEW") !== "1"; component: VeldoraNotices {} }
    Variants {
        model: Quickshell.screens
        delegate: VeldoraTop { required property var modelData; screen: modelData }
    }
    Variants {
        model: Quickshell.screens
        delegate: VeldoraDock { required property var modelData; screen: modelData }
    }
    IpcHandler {
        target: "veldora"
        function overview(): void { VeldoraState.toggleOverview(); }
        function island(): void { VeldoraState.toggleIsland(); }
        function privacy(value: bool): void { VeldoraState.setPrivacy(value); }
        function launcher(): void { VeldoraState.toggleLauncher(); }
        function controls(): void { VeldoraState.toggleControls(); }
        function close(): void { VeldoraState.closePanels(); }
        function status(): string { return JSON.stringify({overview:VeldoraState.overviewOpen,page:VeldoraState.islandPage,focus:VeldoraState.focusMode,reducedMotion:VeldoraState.reducedMotion,dockPinned:VeldoraState.dockPinned,privacy:VeldoraState.privacyMode,island:VeldoraState.islandState,events:VeldoraState.history.length,dockApps:VeldoraState.dockApps.map(a => ({id:a.id,windows:a.windows.length})),controls:VeldoraState.controlsOpen, launcher:VeldoraState.launcherOpen, volume:VeldoraState.volume, brightness:VeldoraState.hardware.brightness, applications:VeldoraState.applications.length, osd:VeldoraState.osdKind}); }
        function volume(value: real): void { VeldoraState.setVolume(value); }
        function workspace(value: int): void { VeldoraState.activateWorkspace(value); }
    }
}
