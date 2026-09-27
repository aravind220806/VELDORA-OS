import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: veldoraOverview
    visible: VeldoraState.overviewOpen && !VeldoraState.privacyMode
    WlrLayershell.namespace: "veldora-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    property int veldoraSelected: 0
    readonly property int veldoraColumns: width >= 1100 ? 5 : width >= 760 ? 4 : 2
    readonly property var veldoraSpaces: {
        const veldoraIds = Array.from({length:VeldoraState.settings.workspaceCount || 10}, (_,i) => i+1);
        for (const veldoraSpace of Hyprland.workspaces.values) if (veldoraSpace.id > 0 && !veldoraIds.includes(veldoraSpace.id)) veldoraIds.push(veldoraSpace.id);
        return veldoraIds.sort((a,b) => a-b);
    }
    readonly property var veldoraMatches: {
        const veldoraQuery = veldoraSearch.text.trim().toLowerCase();
        if (!veldoraQuery) return [];
        const veldoraWindows = Hyprland.toplevels.values.filter(w => (w.title + " " + (w.lastIpcObject.class || "")).toLowerCase().includes(veldoraQuery)).map(w => ({title:w.title,subtitle:"Open window · Space " + (w.workspace ? w.workspace.id : ""),appId:w.lastIpcObject.class,window:w,entry:null}));
        const veldoraApps = VeldoraState.applications.filter(a => (a.name + " " + a.genericName).toLowerCase().includes(veldoraQuery)).map(a => ({title:a.name,subtitle:a.genericName || "Application",appId:a.id,entry:a,window:null}));
        return veldoraWindows.concat(veldoraApps);
    }
    onVisibleChanged: if (visible) { veldoraSearch.text = ""; veldoraSelected = Math.max(0, veldoraSpaces.indexOf(Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1)); veldoraSearch.forceActiveFocus(); }
    function veldoraChoose() {
        if (veldoraSearch.text.trim()) {
            const veldoraMatch = veldoraMatches[veldoraResults.currentIndex];
            if (!veldoraMatch) return;
            if (veldoraMatch.window) VeldoraState.activateWindow(veldoraMatch.window.address);
            else veldoraMatch.entry.execute();
        } else VeldoraState.activateWorkspace(veldoraSpaces[veldoraSelected]);
        VeldoraState.overviewOpen = false;
    }
    MouseArea { anchors.fill: parent; onClicked: VeldoraState.overviewOpen = false }
    ColumnLayout {
        id: veldoraOverviewBody
        anchors { top: parent.top; topMargin: VeldoraTokens.sizes.bar + VeldoraTokens.spacing.lg; horizontalCenter: parent.horizontalCenter }
        width: Math.min(parent.width - VeldoraTokens.spacing.lg * 4, 1760)
        height: Math.min(parent.height - VeldoraTokens.sizes.bar * 3, veldoraSearch.text.trim() ? 560 : 520)
        spacing: VeldoraTokens.spacing.lg
        VeldoraGlass {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(veldoraOverviewBody.width, VeldoraTokens.sizes.launcherWidth)
            Layout.preferredHeight: VeldoraTokens.sizes.iconHover
            MouseArea { anchors.fill: parent }
            RowLayout {
                anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm; spacing: VeldoraTokens.spacing.sm
                VeldoraIcon { text: "search"; color: VeldoraTokens.colors.accent }
                TextField {
                    id: veldoraSearch
                    Layout.fillWidth: true; background: Item {}
                    placeholderText: "Find an app or window…"; placeholderTextColor: VeldoraTokens.colors.textDim
                    color: VeldoraTokens.colors.text; font.family: VeldoraTokens.font.text; font.pixelSize: VeldoraTokens.font.size
                    selectionColor: VeldoraTokens.accentSoft
                    Accessible.name: "Search apps and open windows"
                    onTextChanged: veldoraResults.currentIndex = 0
                    onAccepted: veldoraOverview.veldoraChoose()
                    Keys.onEscapePressed: VeldoraState.overviewOpen = false
                    Keys.onDownPressed: { if (text.trim()) veldoraResults.currentIndex = Math.min(veldoraOverview.veldoraMatches.length-1, veldoraResults.currentIndex+1); else veldoraOverview.veldoraSelected = Math.min(veldoraOverview.veldoraSpaces.length-1, veldoraOverview.veldoraSelected+veldoraOverview.veldoraColumns); }
                    Keys.onUpPressed: { if (text.trim()) veldoraResults.currentIndex = Math.max(0,veldoraResults.currentIndex-1); else veldoraOverview.veldoraSelected = Math.max(0,veldoraOverview.veldoraSelected-veldoraOverview.veldoraColumns); }
                    Keys.onLeftPressed: event => { if (!text) veldoraOverview.veldoraSelected = Math.max(0,veldoraOverview.veldoraSelected-1); else event.accepted = false; }
                    Keys.onRightPressed: event => { if (!text) veldoraOverview.veldoraSelected = Math.min(veldoraOverview.veldoraSpaces.length-1,veldoraOverview.veldoraSelected+1); else event.accepted = false; }
                }
                VeldoraButton { veldoraIcon: "apps"; onClicked: VeldoraState.toggleLauncher(); Accessible.name: "Browse applications" }
                VeldoraButton { veldoraIcon: "close"; onClicked: VeldoraState.overviewOpen = false; Accessible.name: "Close overview" }
            }
        }
        VeldoraGlass {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: VeldoraTokens.radius.card
            MouseArea { anchors.fill: parent }
            ColumnLayout {
                anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.lg
                spacing: VeldoraTokens.spacing.md
                RowLayout {
                    VeldoraText { text: veldoraSearch.text.trim() ? "Find your flow" : "Your spaces"; font.pixelSize: VeldoraTokens.font.heading; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    VeldoraText { text: veldoraSearch.text.trim() ? veldoraOverview.veldoraMatches.length + " matches" : "VELDORA  /  OVERVIEW"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
                }
                ScrollView {
                    id: veldoraWorkspaceScroll
                    visible: !veldoraSearch.text.trim(); Layout.fillWidth: true; Layout.fillHeight: true
                    contentWidth: availableWidth; clip: true
                    GridLayout {
                        width: parent.width
                        columns: veldoraOverview.veldoraColumns
                        columnSpacing: VeldoraTokens.spacing.sm; rowSpacing: VeldoraTokens.spacing.sm
                        Repeater {
                            model: veldoraOverview.veldoraSpaces
                            delegate: Rectangle {
                                id: veldoraSpace
                                required property int modelData
                                required property int index
                                readonly property var veldoraWindows: Hyprland.toplevels.values.filter(w => w.workspace && w.workspace.id === modelData)
                                readonly property bool veldoraActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: Math.max(120, Math.min(172, (veldoraWorkspaceScroll.availableHeight - VeldoraTokens.spacing.sm * (Math.ceil(veldoraOverview.veldoraSpaces.length / veldoraOverview.veldoraColumns)-1)) / Math.ceil(veldoraOverview.veldoraSpaces.length / veldoraOverview.veldoraColumns)))
                                radius: VeldoraTokens.radius.tile
                                color: veldoraActive ? VeldoraTokens.accentSoft : VeldoraTokens.colors.surfaceHigh
                                border.width: veldoraOverview.veldoraSelected === index ? 2 : 1
                                border.color: veldoraOverview.veldoraSelected === index ? VeldoraTokens.colors.accent : VeldoraTokens.border
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { VeldoraState.activateWorkspace(veldoraSpace.modelData); VeldoraState.overviewOpen = false; } }
                                VeldoraText { anchors.centerIn: parent; visible: !veldoraSpace.veldoraWindows.length; text: String(veldoraSpace.modelData).padStart(2,"0"); font.pixelSize: VeldoraTokens.sizes.close; color: VeldoraTokens.colors.textDim }
                                Row {
                                    anchors { left: parent.left; right: parent.right; top: parent.top; bottom: veldoraSpaceLabel.top; margins: VeldoraTokens.spacing.sm }
                                    spacing: VeldoraTokens.spacing.xs
                                    Repeater {
                                        model: veldoraSpace.veldoraWindows.slice(0,4)
                                        delegate: Rectangle {
                                            id: veldoraPreview
                                            required property var modelData
                                            width: (parent.width - parent.spacing * (Math.min(4,veldoraSpace.veldoraWindows.length)-1)) / Math.min(4,veldoraSpace.veldoraWindows.length)
                                            height: parent.height
                                            radius: VeldoraTokens.radius.small; color: VeldoraTokens.colors.background; clip: true
                                            ScreencopyView {
                                                id: veldoraCapture
                                                anchors.centerIn: parent
                                                width: parent.width; height: Math.min(parent.height, parent.width * (sourceSize.height / Math.max(1,sourceSize.width)))
                                                captureSource: veldoraOverview.visible ? veldoraPreview.modelData.wayland : null
                                                live: veldoraOverview.visible
                                                paintCursor: false
                                            }
                                            VeldoraAppIcon { anchors.centerIn: parent; visible: !veldoraCapture.hasContent; veldoraAppId: veldoraPreview.modelData.lastIpcObject.class || "" }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { VeldoraState.activateWindow(veldoraPreview.modelData.address); VeldoraState.overviewOpen = false; } }
                                        }
                                    }
                                }
                                RowLayout {
                                    id: veldoraSpaceLabel
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: VeldoraTokens.spacing.sm }
                                    VeldoraText { text: "Space " + veldoraSpace.modelData; color: veldoraSpace.veldoraActive ? VeldoraTokens.colors.accent : VeldoraTokens.colors.text; Layout.fillWidth: true; font.pixelSize: VeldoraTokens.font.small }
                                    VeldoraText { text: veldoraSpace.veldoraWindows.length ? veldoraSpace.veldoraWindows.length + " open" : "Make room"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
                                }
                            }
                        }
                    }
                }
                ListView {
                    id: veldoraResults
                    visible: !!veldoraSearch.text.trim(); Layout.fillWidth: true; Layout.fillHeight: true
                    model: veldoraOverview.veldoraMatches; clip: true; spacing: VeldoraTokens.spacing.xs
                    currentIndex: 0
                    delegate: VeldoraTile {
                        required property var modelData
                        required property int index
                        width: veldoraResults.width
                        text: modelData.title; veldoraSubtitle: modelData.subtitle; veldoraIcon: modelData.window ? "select_window" : "apps"
                        veldoraOn: ListView.isCurrentItem
                        onClicked: { veldoraResults.currentIndex = index; veldoraOverview.veldoraChoose(); }
                    }
                    VeldoraText { anchors.centerIn: parent; visible: !veldoraResults.count; text: "No apps or windows found"; color: VeldoraTokens.colors.textDim }
                }
                VeldoraText { text: "Arrows to explore   ·   Enter to open   ·   Esc to return"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
            }
        }
    }
}
