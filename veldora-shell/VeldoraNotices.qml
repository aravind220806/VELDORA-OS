import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: veldoraNotices
    NotificationServer {
        id: veldoraServer
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        onNotification: veldoraNotice => {
            veldoraNotice.tracked = true;
            if (VeldoraState.focusMode) veldoraNotice.dismiss();
            else if (trackedNotifications.values.length > 4) trackedNotifications.values[0].expire();
        }
    }
    PanelWindow {
        id: veldoraNoticeWindow
        visible: veldoraServer.trackedNotifications.values.length > 0
        WlrLayershell.namespace: "veldora-notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        anchors { top: true; right: true }
        margins { top: VeldoraTokens.sizes.bar + VeldoraTokens.spacing.lg; right: VeldoraTokens.spacing.sm }
        implicitWidth: VeldoraTokens.sizes.notificationWidth + VeldoraTokens.values.shadow.blur * 2
        implicitHeight: veldoraNoticeColumn.implicitHeight + VeldoraTokens.values.shadow.blur * 2
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: Region { item: veldoraNoticeColumn }
        Column {
            id: veldoraNoticeColumn
            x: VeldoraTokens.values.shadow.blur; y: VeldoraTokens.values.shadow.blur
            width: VeldoraTokens.sizes.notificationWidth
            spacing: VeldoraTokens.spacing.sm
            Repeater {
                model: veldoraServer.trackedNotifications
                delegate: VeldoraGlass {
                    id: veldoraNoticeCard
                    required property var modelData
                    width: veldoraNoticeColumn.width
                    height: veldoraNoticeContent.implicitHeight + VeldoraTokens.spacing.md * 2
                    radius: VeldoraTokens.radius.notification
                    property real veldoraSlide: 1
                    transform: Translate { x: veldoraNoticeCard.veldoraSlide * veldoraNoticeCard.width }
                    opacity: 1 - veldoraSlide
                    Component.onCompleted: veldoraSlide = 0
                    Behavior on veldoraSlide { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack } }
                    Timer { interval: VeldoraTokens.values.timing.notification; running: true; onTriggered: veldoraNoticeCard.modelData.expire() }
                    Rectangle { x: VeldoraTokens.spacing.xs; y: VeldoraTokens.spacing.md; width: 3; height: parent.height - VeldoraTokens.spacing.md * 2; radius: VeldoraTokens.radius.pill; color: VeldoraTokens.colors.accent }
                    ColumnLayout {
                        id: veldoraNoticeContent
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: VeldoraTokens.spacing.md }
                        spacing: VeldoraTokens.spacing.xs
                        RowLayout {
                            Layout.fillWidth: true
                            VeldoraText { Layout.fillWidth: true; text: veldoraNoticeCard.modelData.appName || "Veldora"; color: VeldoraTokens.colors.accent; font.pixelSize: VeldoraTokens.font.small }
                            VeldoraButton { veldoraIcon: "close"; onClicked: veldoraNoticeCard.modelData.dismiss(); Accessible.name: "Dismiss notification" }
                        }
                        VeldoraText { Layout.fillWidth: true; text: veldoraNoticeCard.modelData.summary; font.weight: Font.DemiBold; wrapMode: Text.Wrap; maximumLineCount: 2 }
                        VeldoraText { Layout.fillWidth: true; text: veldoraNoticeCard.modelData.body.replace(/<[^>]*>/g, ""); wrapMode: Text.Wrap; maximumLineCount: 4; color: VeldoraTokens.colors.textDim; visible: text.length > 0 }
                        Flow {
                            Layout.fillWidth: true; spacing: VeldoraTokens.spacing.xs
                            Repeater {
                                model: veldoraNoticeCard.modelData.actions
                                delegate: VeldoraButton { required property var modelData; text: modelData.text; onClicked: modelData.invoke() }
                            }
                        }
                    }
                }
            }
        }
    }
}
