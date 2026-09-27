import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: veldoraIsland
    screen: Quickshell.screens[0] || null
    visible: VeldoraState.islandOpen && !VeldoraState.privacyMode
    WlrLayershell.namespace: "veldora-veldock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors.top: true
    margins.top: VeldoraTokens.sizes.bar + VeldoraTokens.spacing.lg
    implicitWidth: Math.min(480, (screen ? screen.width : 600) - VeldoraTokens.spacing.lg * 2)
    implicitHeight: Math.min(480, (screen ? screen.height : 768) - VeldoraTokens.sizes.bar * 3)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    onVisibleChanged: if (visible) veldoraIslandCard.forceActiveFocus()
    mask: Region { item: veldoraIslandCard }
    VeldoraGlass {
        id: veldoraIslandCard
        anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.sm
        radius: VeldoraTokens.radius.card
        focus: true
        Keys.onEscapePressed: VeldoraState.islandOpen = false
        Keys.onLeftPressed: veldoraTabs.currentIndex = Math.max(0,veldoraTabs.currentIndex-1)
        Keys.onRightPressed: veldoraTabs.currentIndex = Math.min(4,veldoraTabs.currentIndex+1)
        ColumnLayout {
            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.lg
            spacing: VeldoraTokens.spacing.sm
            RowLayout {
                VeldoraText { text: "VelDock"; font.pixelSize: VeldoraTokens.font.heading; font.weight: Font.DemiBold; Layout.fillWidth: true }
                VeldoraText { text: VeldoraState.history.length + " events"; color: VeldoraTokens.colors.textDim; font.pixelSize: VeldoraTokens.font.small }
                VeldoraButton { veldoraIcon: "close"; veldoraFilled: true; onClicked: VeldoraState.islandOpen = false; Accessible.name: "Close VelDock" }
            }
            TabBar {
                id: veldoraTabs
                Layout.fillWidth: true
                currentIndex: ["Media","Audio","Events","Apps","Settings"].indexOf(VeldoraState.islandPage)
                onCurrentIndexChanged: if (currentIndex >= 0) VeldoraState.islandPage = ["Media","Audio","Events","Apps","Settings"][currentIndex]
                background: Item {}
                Repeater {
                    model: ["Media","Audio","Events","Apps","Settings"]
                    delegate: TabButton {
                        id: veldoraTab
                        required property string modelData
                        text: modelData; implicitHeight: VeldoraTokens.sizes.close
                        contentItem: VeldoraText { text: veldoraTab.text; horizontalAlignment: Text.AlignHCenter; color: veldoraTab.checked ? VeldoraTokens.colors.accent : VeldoraTokens.colors.textDim }
                        background: Rectangle { radius: VeldoraTokens.radius.pill; color: veldoraTab.checked ? VeldoraTokens.accentSoft : "transparent"; border.width: veldoraTab.visualFocus ? 1 : 0; border.color: VeldoraTokens.colors.accent }
                    }
                }
            }
            StackLayout {
                currentIndex: veldoraTabs.currentIndex
                Layout.fillWidth: true; Layout.fillHeight: true
                ColumnLayout {
                    spacing: VeldoraTokens.spacing.sm
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        radius: VeldoraTokens.radius.tile; color: VeldoraTokens.colors.surfaceHigh
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: VeldoraTokens.spacing.lg
                            VeldoraIcon { text: "graphic_eq"; font.pixelSize: VeldoraTokens.sizes.icon; color: VeldoraTokens.colors.accent }
                            VeldoraText { text: VeldoraState.player ? VeldoraState.player.trackTitle || "Now playing" : "A little room to breathe"; wrapMode: Text.Wrap; maximumLineCount: 3; Layout.fillWidth: true; font.pixelSize: VeldoraTokens.font.heading }
                            VeldoraText { text: VeldoraState.player ? VeldoraState.player.trackArtist : "Play music or video in a compatible app."; Layout.fillWidth: true; wrapMode: Text.Wrap; color: VeldoraTokens.colors.textDim }
                            Item { Layout.fillHeight: true }
                        }
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        VeldoraButton { veldoraIcon: "skip_previous"; enabled: !!VeldoraState.player && VeldoraState.player.canGoPrevious; onClicked: VeldoraState.player.previous() }
                        VeldoraButton { veldoraIcon: VeldoraState.player && VeldoraState.player.isPlaying ? "pause" : "play_arrow"; text: VeldoraState.player && VeldoraState.player.isPlaying ? "Pause" : "Play"; veldoraFilled: true; enabled: !!VeldoraState.player && VeldoraState.player.canTogglePlaying; onClicked: VeldoraState.player.togglePlaying() }
                        VeldoraButton { veldoraIcon: "skip_next"; enabled: !!VeldoraState.player && VeldoraState.player.canGoNext; onClicked: VeldoraState.player.next() }
                    }
                }
                ColumnLayout {
                    spacing: VeldoraTokens.spacing.sm
                    VeldoraTile { Layout.fillWidth: true; text: "Sound"; veldoraIcon: VeldoraState.muted ? "volume_off" : "volume_up"; veldoraSubtitle: VeldoraState.sink ? Math.round(VeldoraState.volume*100)+"%"+(VeldoraState.volume>1 ? " · Boost" : "") : "No output device"; veldoraOn: !VeldoraState.muted; enabled: !!VeldoraState.sink; onClicked: VeldoraState.sink.audio.muted = !VeldoraState.muted }
                    VeldoraSlider { Layout.fillWidth: true; enabled: !!VeldoraState.sink; value: Math.min(1,VeldoraState.volume); veldoraDanger: VeldoraState.volume>1; onMoved: VeldoraState.setVolume(value); Accessible.name: "VelDock volume" }
                    VeldoraText { text: VeldoraState.hardware.brightness >= 0 ? "Brightness · " + VeldoraState.hardware.brightness + "%" : "Brightness unavailable"; color: VeldoraTokens.colors.textDim }
                    VeldoraSlider { Layout.fillWidth: true; enabled: VeldoraState.hardware.brightness >= 0; from:0.01; value:Math.max(0.01,VeldoraState.hardware.brightness/100); onMoved: VeldoraState.action(["brightnessctl","set",Math.round(value*100)+"%"]); Accessible.name: "VelDock brightness" }
                    VeldoraTile { Layout.fillWidth: true; text: "Network"; veldoraIcon: "wifi"; veldoraSubtitle: VeldoraState.hardware.network; onClicked: VeldoraState.toggleControls() }
                    Item { Layout.fillHeight: true }
                }
                ColumnLayout {
                    spacing: VeldoraTokens.spacing.sm
                    RowLayout {
                        VeldoraButton { text: VeldoraState.focusMode ? "Focus on" : "Focus off"; veldoraIcon:"do_not_disturb_on"; veldoraSelected:VeldoraState.focusMode; onClicked: VeldoraState.focusMode = !VeldoraState.focusMode }
                        Item { Layout.fillWidth: true }
                        VeldoraButton { text:"Clear"; onClicked: VeldoraState.history = [] }
                    }
                    ListView {
                        Layout.fillWidth:true; Layout.fillHeight:true; clip:true; spacing:VeldoraTokens.spacing.sm
                        model:VeldoraState.history
                        delegate: Rectangle {
                            id: veldoraEventCard
                            required property var modelData
                            width: ListView.view.width; height:veldoraEventColumn.implicitHeight+VeldoraTokens.spacing.sm*2
                            radius:VeldoraTokens.radius.tile; color:VeldoraTokens.colors.surfaceHigh
                            ColumnLayout {
                                id:veldoraEventColumn
                                anchors { left:parent.left; right:parent.right; top:parent.top; margins:VeldoraTokens.spacing.sm }
                                spacing:VeldoraTokens.spacing.xs
                                RowLayout {
                                    VeldoraText { text:veldoraEventCard.modelData.source; color:VeldoraTokens.colors.accent; font.pixelSize:VeldoraTokens.font.small; Layout.fillWidth:true }
                                    VeldoraButton { veldoraIcon:"close"; onClicked:VeldoraState.dismissEvent(veldoraEventCard.modelData.id); Accessible.name:"Dismiss event" }
                                }
                                VeldoraText { text:veldoraEventCard.modelData.title; Layout.fillWidth:true; wrapMode:Text.Wrap; maximumLineCount:2 }
                                VeldoraText { text:veldoraEventCard.modelData.body; Layout.fillWidth:true; wrapMode:Text.Wrap; maximumLineCount:3; color:VeldoraTokens.colors.textDim; visible:!!text }
                            }
                        }
                        VeldoraText { anchors.centerIn:parent; visible:!VeldoraState.history.length; text:"Nothing waiting for you"; color:VeldoraTokens.colors.textDim }
                    }
                }
                ColumnLayout {
                    spacing:VeldoraTokens.spacing.sm
                    VeldoraTile { Layout.fillWidth:true; text:"All applications"; veldoraSubtitle:"Search your installed tools"; veldoraIcon:"apps"; onClicked:VeldoraState.toggleLauncher() }
                    VeldoraTile { Layout.fillWidth:true; text:"Your spaces"; veldoraSubtitle:"Windows and workspace overview"; veldoraIcon:"view_module"; onClicked:VeldoraState.toggleOverview() }
                    VeldoraTile { Layout.fillWidth:true; text:"Security workbench"; veldoraSubtitle:"Engagements, notes and evidence"; veldoraIcon:"shield"; onClicked:{ VeldoraState.islandOpen=false; Quickshell.execDetached(["veldora-workbench"]); } }
                    Item { Layout.fillHeight:true }
                }
                ColumnLayout {
                    spacing:VeldoraTokens.spacing.sm
                    VeldoraTile { Layout.fillWidth:true; text:"Reduced motion"; veldoraSubtitle:VeldoraState.reducedMotion ? "Shell transitions off" : "Soft shell transitions"; veldoraIcon:"motion_photos_off"; veldoraOn:VeldoraState.reducedMotion; onClicked:VeldoraState.setPreference("reducedMotion", !VeldoraState.reducedMotion) }
                    VeldoraTile { Layout.fillWidth:true; text:"Pin app dock"; veldoraSubtitle:VeldoraState.dockPinned ? "Always visible" : "Reveal at the bottom edge"; veldoraIcon:"keep"; veldoraOn:VeldoraState.dockPinned; onClicked:VeldoraState.setPreference("dockPinned", !VeldoraState.dockPinned) }
                    VeldoraTile { Layout.fillWidth:true; text:"Hide private history"; veldoraSubtitle:"Clear events and return to the clock"; veldoraIcon:"visibility_off"; onClicked:{ VeldoraState.history=[]; VeldoraState.privacyVeil=true; VeldoraState.islandOpen=false; } }
                    VeldoraText { Layout.fillWidth:true; text:"Sentinel and managed job services are not available in this build."; wrapMode:Text.Wrap; color:VeldoraTokens.colors.textDim; font.pixelSize:VeldoraTokens.font.small }
                    Item { Layout.fillHeight:true }
                }
            }
        }
    }
}
