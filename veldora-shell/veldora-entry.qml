import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    VeldoraControls {}
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
        function launcher(): void { VeldoraState.toggleLauncher(); }
        function controls(): void { VeldoraState.toggleControls(); }
        function close(): void { VeldoraState.launcherOpen = false; VeldoraState.controlsOpen = false; }
        function status(): string { return JSON.stringify({controls:VeldoraState.controlsOpen, launcher:VeldoraState.launcherOpen, volume:VeldoraState.volume, brightness:VeldoraState.hardware.brightness, applications:VeldoraState.applications.length, osd:VeldoraState.osdKind}); }
        function volume(value: real): void { VeldoraState.setVolume(value); }
        function workspace(value: int): void { VeldoraState.activateWorkspace(value); }
    }
}
