import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: veldoraLauncher
    visible: VeldoraState.launcherOpen
    WlrLayershell.namespace: "veldora-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    onVisibleChanged: {
        if (visible) { veldoraSearch.text = ""; veldoraResults.currentIndex = 0; veldoraSearch.forceActiveFocus(); }
    }
    MouseArea { anchors.fill: parent; onClicked: VeldoraState.launcherOpen = false }
    VeldoraGlass {
        id: veldoraLaunchCard
        anchors.centerIn: parent
        width: Math.min(VeldoraTokens.sizes.launcherWidth, parent.width - VeldoraTokens.spacing.lg * 2)
        height: Math.min(parent.height - VeldoraTokens.sizes.bar * 4, VeldoraTokens.sizes.icon * 12)
        radius: VeldoraTokens.radius.card
        MouseArea { anchors.fill: parent }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.lg
            spacing: VeldoraTokens.spacing.sm
            RowLayout {
                Layout.fillWidth: true
                VeldoraText { text: "Find your next thing"; font.pixelSize: VeldoraTokens.font.heading; font.weight: Font.DemiBold; Layout.fillWidth: true }
                VeldoraButton { veldoraIcon: "close"; onClicked: VeldoraState.launcherOpen = false; Accessible.name: "Close launcher" }
            }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: VeldoraTokens.sizes.iconHover
                color: VeldoraTokens.colors.surfaceHigh; radius: VeldoraTokens.radius.pill
                border.color: VeldoraTokens.accentSoft; border.width: 1
                RowLayout {
                    anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.md; spacing: VeldoraTokens.spacing.sm
                    VeldoraIcon { text: "search"; color: VeldoraTokens.colors.accent }
                    TextField {
                        id: veldoraSearch
                        Layout.fillWidth: true
                        color: VeldoraTokens.colors.text
                        font.family: VeldoraTokens.font.text; font.pixelSize: VeldoraTokens.font.size
                        placeholderText: "Search applications…"; placeholderTextColor: VeldoraTokens.colors.textDim
                        selectionColor: VeldoraTokens.accentSoft
                        background: Item {}
                        Accessible.name: "Search applications"
                        onTextChanged: veldoraResults.currentIndex = 0
                        onAccepted: veldoraLauncher.veldoraLaunch()
                        Keys.onEscapePressed: VeldoraState.launcherOpen = false
                        Keys.onDownPressed: veldoraResults.currentIndex = Math.min(veldoraResults.count - 1, veldoraResults.currentIndex + 1)
                        Keys.onUpPressed: veldoraResults.currentIndex = Math.max(0, veldoraResults.currentIndex - 1)
                    }
                }
            }
            VeldoraText { text: veldoraSearch.text ? veldoraResults.count + " applications" : "APPLICATIONS"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
            ListView {
                id: veldoraResults
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; spacing: VeldoraTokens.spacing.xs
                model: VeldoraState.applications.filter(a => (a.name + " " + a.genericName + " " + a.id).toLowerCase().includes(veldoraSearch.text.toLowerCase()))
                currentIndex: 0
                highlightMoveDuration: VeldoraTokens.duration
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    id: veldoraResult
                    required property var modelData
                    required property int index
                    width: veldoraResults.width; height: VeldoraTokens.sizes.icon + VeldoraTokens.spacing.sm * 2
                    radius: VeldoraTokens.radius.tile
                    color: ListView.isCurrentItem || veldoraResultMouse.containsMouse ? VeldoraTokens.accentSoft : "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm; spacing: VeldoraTokens.spacing.sm
                        Rectangle {
                            Layout.preferredWidth: VeldoraTokens.sizes.icon; Layout.preferredHeight: width
                            radius: VeldoraTokens.radius.pill; color: VeldoraTokens.colors.surfaceHigh
                            VeldoraAppIcon { anchors.centerIn: parent; veldoraAppId: veldoraResult.modelData.id }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 0
                            VeldoraText { Layout.fillWidth: true; text: veldoraResult.modelData.name; font.weight: Font.Medium }
                            VeldoraText { Layout.fillWidth: true; text: veldoraResult.modelData.genericName || veldoraResult.modelData.comment || veldoraResult.modelData.id; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
                        }
                        VeldoraIcon { text: "north_east"; color: VeldoraTokens.colors.textDim }
                    }
                    MouseArea { id: veldoraResultMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { veldoraResults.currentIndex = veldoraResult.index; veldoraLauncher.veldoraLaunch(); } }
                }
                VeldoraText { anchors.centerIn: parent; visible: veldoraResults.count === 0; text: "No applications found"; color: VeldoraTokens.colors.textDim }
            }
            VeldoraText { text: "↑ ↓  Navigate     Enter  Open     Esc  Close"; font.pixelSize: VeldoraTokens.font.small; color: VeldoraTokens.colors.textDim }
        }
    }
    function veldoraLaunch() {
        if (veldoraResults.currentIndex >= 0 && veldoraResults.currentIndex < veldoraResults.count) {
            veldoraResults.model[veldoraResults.currentIndex].execute();
            VeldoraState.launcherOpen = false;
        }
    }
}
