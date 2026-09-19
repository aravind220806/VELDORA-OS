// SPDX-License-Identifier: GPL-3.0-or-later
// Modified 2026-09-14: Storm palette, geometry and motion.
// Veldora entry point for pinned end-4 illogical-impulse.
//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
import QtQuick
import Quickshell
import Quickshell.Io
import "modules/common"
import "services"
import "panelFamilies"
import "modules/veldora/veldock"
import "modules/veldora/theme"
ShellRoot {
    Component.onCompleted: {
        MaterialThemeLoader.filePath = Quickshell.shellPath(Storm.ember ? "ember.json" : "storm.json");
        MaterialThemeLoader.reapplyTheme();
        Appearance.rounding.small = 8;
        Appearance.rounding.normal = 10;
        Appearance.rounding.large = 14;
        Appearance.rounding.verylarge = 18;
        Appearance.animation.elementMove.duration = Qt.binding(() => Storm.duration);
        Appearance.animation.elementMoveSmall.duration = Qt.binding(() => Storm.reducedMotion ? 0 : 140);
    }
    LazyLoader {
        active: Config.ready
        component: IllogicalImpulseFamily {}
    }
    VelDock {}
    IpcHandler {
        target: "veldora"
        function toggle(): void { DockState.toggle(); }
        function launcher(): void { DockState.open("Apps"); }
        function close(): void { DockState.close(); }
        function page(name: string): void { if (["Media", "Audio", "Events", "Apps", "Settings"].includes(name)) DockState.open(name); }
        function status(): string { return JSON.stringify({state: DockState.state, count: DockState.history.length, active: DockState.active?.id ?? null, opened: DockState.opened, locked: DockState.locked, reducedMotion: Storm.reducedMotion}); }
    }
}
