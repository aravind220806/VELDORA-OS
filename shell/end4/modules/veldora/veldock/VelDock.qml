// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.veldora.theme
Scope {
    PanelWindow {
        id: panel
        screen: DockState.primary
        visible: DockState.opened && !DockState.locked && !!DockState.primary
        anchors.top: true
        margins.top: 48
        implicitWidth: Math.max(240, Math.min(464, (screen?.width ?? 480) - 24))
        implicitHeight: Math.max(200, Math.min(DockState.page === "Apps" ? 520 : 420, (screen?.height ?? 768) - 80))
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "veldora-veldock"
        // Only an explicit user action makes this window visible and requests focus.
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        property var player: MprisController.activePlayer
        property var monitor: Brightness.getMonitorForScreen(screen)
        onVisibleChanged: if (visible) body.forceActiveFocus()
        Rectangle {
            id: body
            anchors.fill: parent
            radius: 24
            color: Storm.surface
            border.color: Storm.border
            border.width: 1
            focus: true
            Keys.onEscapePressed: DockState.close()
            Keys.onLeftPressed: tabs.decrementCurrentIndex()
            Keys.onRightPressed: tabs.incrementCurrentIndex()
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8
                RowLayout {
                    Text { text: "VelDock"; font.family: Storm.font; font.pixelSize: 19; font.weight: Font.DemiBold; color: Storm.text; Layout.fillWidth: true }
                    Text { text: DockState.history.length + " events"; color: Storm.secondary; font.pixelSize: 12 }
                    Action { text: "Close"; onClicked: DockState.close() }
                }
                TabBar {
                    id: tabs
                    Layout.fillWidth: true
                    currentIndex: ["Media", "Audio", "Events", "Apps", "Settings"].indexOf(DockState.page)
                    onCurrentIndexChanged: if (currentIndex >= 0) DockState.page = ["Media", "Audio", "Events", "Apps", "Settings"][currentIndex]
                    Repeater {
                        model: ["Media", "Audio", "Events", "Apps", "Settings"]
                        TabButton {
                            id: tab
                            required property string modelData
                            text: modelData
                            Accessible.name: modelData
                            contentItem: Text { text: tab.text; color: tab.checked ? Storm.accent : Storm.secondary; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 12 }
                            background: Rectangle { radius: 8; color: Storm.raised; border.width: tab.activeFocus ? 2 : 0; border.color: Storm.accent }
                        }
                    }
                }
                StackLayout {
                    currentIndex: tabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        spacing: 12
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            color: Storm.raised; radius: 16
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 16
                                Text { text: "♫"; color: Storm.accent; font.pixelSize: 36 }
                                Text { text: panel.player?.trackTitle || "No active player"; textFormat: Text.PlainText; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight; Layout.fillWidth: true; color: Storm.text; font.pixelSize: 18 }
                                Text { text: panel.player?.trackArtist || "Start music or video in an MPRIS-compatible app."; textFormat: Text.PlainText; wrapMode: Text.Wrap; Layout.fillWidth: true; color: Storm.secondary; font.pixelSize: 13 }
                                Item { Layout.fillHeight: true }
                            }
                        }
                        RowLayout {
                            Action { text: "Previous"; Layout.fillWidth: true; enabled: panel.player?.canGoPrevious ?? false; onClicked: panel.player.previous() }
                            Action { text: panel.player?.isPlaying ? "Pause" : "Play"; Layout.fillWidth: true; enabled: panel.player?.canTogglePlaying ?? false; onClicked: panel.player.togglePlaying() }
                            Action { text: "Next"; Layout.fillWidth: true; enabled: panel.player?.canGoNext ?? false; onClicked: panel.player.next() }
                        }
                    }
                    ColumnLayout {
                        spacing: 8
                        Text { text: Audio.ready ? "Output · " + Math.round(Audio.value * 100) + "%" : "Audio output unavailable"; color: Storm.text; font.pixelSize: 14 }
                        Slider { Layout.fillWidth: true; from: 0; to: 1; value: Audio.value; enabled: Audio.ready; onMoved: Audio.sink.audio.volume = value; Accessible.name: "Output volume" }
                        RowLayout {
                            Action { text: Audio.sink?.audio.muted ? "Unmute output" : "Mute output"; enabled: Audio.ready; onClicked: Audio.toggleMute() }
                            Action { text: Audio.source?.audio.muted ? "Unmute mic" : "Mute mic"; enabled: !!Audio.source; onClicked: Audio.toggleMicMute() }
                        }
                        Text { text: panel.monitor?.ready ? "Display brightness" : "Brightness control unavailable"; color: Storm.text; font.pixelSize: 14 }
                        Slider { Layout.fillWidth: true; from: 0.05; to: 1; value: panel.monitor?.brightness ?? 1; enabled: panel.monitor?.ready ?? false; onMoved: panel.monitor.setBrightness(value); Accessible.name: "Display brightness" }
                        Text { text: Network.ethernet ? "Ethernet connected" : "Wi-Fi · " + Network.wifiStatus; color: Storm.secondary; font.pixelSize: 13 }
                        Action { text: "Open network settings"; onClicked: Quickshell.execDetached(["nm-connection-editor"]) }
                        Item { Layout.fillHeight: true }
                    }
                    ColumnLayout {
                        RowLayout {
                            Action { text: Notifications.silent ? "DND on" : "DND off"; checkable: true; checked: Notifications.silent; onClicked: Notifications.silent = !Notifications.silent }
                            Item { Layout.fillWidth: true }
                            Action { text: "Clear history"; enabled: DockState.history.length > 0; onClicked: DockState.clear() }
                        }
                        ScrollView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            clip: true
                            contentWidth: availableWidth
                            ColumnLayout {
                                width: parent.width
                                Text { visible: DockState.history.length === 0; text: "No recent events."; color: Storm.secondary; font.pixelSize: 14 }
                                Repeater {
                                    model: DockState.history
                                    Rectangle {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        implicitHeight: eventColumn.implicitHeight + 24
                                        color: Storm.raised; radius: 12
                                        ColumnLayout {
                                            id: eventColumn
                                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                                            Text { text: modelData.source + " · " + new Date(modelData.createdAt).toLocaleTimeString(); textFormat: Text.PlainText; color: Storm.secondary; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                                            Text { text: modelData.title; textFormat: Text.PlainText; color: Storm.text; font.pixelSize: 14; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                            Text { text: modelData.body; textFormat: Text.PlainText; color: Storm.secondary; font.pixelSize: 13; Layout.fillWidth: true; wrapMode: Text.Wrap; maximumLineCount: 8; elide: Text.ElideRight }
                                            Action { text: "Dismiss"; onClicked: { if (modelData.kind === "notification") Notifications.discardNotification(Number(modelData.id.split(":")[1])); else DockState.dismiss(modelData.id); } }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        TextField {
                            id: search
                            Layout.fillWidth: true
                            placeholderText: "Search installed applications"
                            Accessible.name: "Search installed applications"
                            color: Storm.text
                            background: Rectangle { color: Storm.raised; radius: 10; border.color: search.activeFocus ? Storm.accent : Storm.border }
                            onAccepted: if (apps.count) { apps.model[apps.currentIndex >= 0 ? apps.currentIndex : 0].execute(); DockState.close(); }
                            Keys.onDownPressed: { apps.forceActiveFocus(); apps.currentIndex = 0; }
                        }
                        ListView {
                            id: apps
                            Layout.fillWidth: true; Layout.fillHeight: true
                            clip: true
                            model: AppSearch.list.filter(app => app.name.toLowerCase().includes(search.text.toLowerCase()))
                            keyNavigationEnabled: true
                            Keys.onReturnPressed: if (currentIndex >= 0) { model[currentIndex].execute(); DockState.close(); }
                            delegate: Action {
                                required property var modelData
                                required property int index
                                width: apps.width
                                text: modelData.name
                                checked: apps.currentIndex === index
                                onClicked: { modelData.execute(); DockState.close(); }
                            }
                        }
                        Text { visible: apps.count === 0; text: "No matching applications."; color: Storm.secondary }
                    }
                    ColumnLayout {
                        Action { text: Storm.reducedMotion ? "Reduced motion: on" : "Reduced motion: off"; Layout.fillWidth: true; onClicked: Storm.reducedMotion = !Storm.reducedMotion }
                        Action { text: Storm.highContrast ? "High contrast: on" : "High contrast: off"; Layout.fillWidth: true; onClicked: Storm.highContrast = !Storm.highContrast }
                        Text { text: "Clipboard collection is off by default. These display toggles last for this session; environment options can set startup defaults."; color: Storm.secondary; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Text { text: "Sentinel: unavailable\nNo protection service is connected."; color: Storm.secondary; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
