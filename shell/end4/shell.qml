// SPDX-License-Identifier: GPL-3.0-or-later
// Veldora entry point for pinned end-4 illogical-impulse.
//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
import QtQuick
import Quickshell
import Quickshell.Io
import "modules/common"
import "services"
import "panelFamilies"
ShellRoot {
    Component.onCompleted: MaterialThemeLoader.reapplyTheme()
    LazyLoader {
        active: Config.ready
        component: IllogicalImpulseFamily {}
    }
    IpcHandler {
        target: "veldora"
        function toggle(): void { GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen; }
    }
}
