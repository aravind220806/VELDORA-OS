// SPDX-License-Identifier: GPL-3.0-or-later
// Veldora layout; uses end-4's native services and widgets.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
Item {
    id: root
    property var screen: QsWindow.window?.screen
    component Pill: Rectangle {
        color: Qt.rgba(0.10, 0.09, 0.13, 0.92)
        radius: height / 2
        border.width: 1
        border.color: Qt.rgba(0.85, 0.80, 0.95, 0.08)
    }
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        Pill {
            implicitWidth: workspaces.implicitWidth + 12
            implicitHeight: 32
            Workspaces { id: workspaces; anchors.centerIn: parent }
        }
        Pill {
            visible: root.width > 1500
            implicitWidth: resources.implicitWidth + 16
            implicitHeight: 32
            Resources { id: resources; anchors.centerIn: parent; alwaysShowAllResources: true }
        }
    }
    VeldoraIsland {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        SysTray { Layout.alignment: Qt.AlignVCenter }
        Pill {
            implicitWidth: status.implicitWidth + 22
            implicitHeight: 32
            RowLayout {
                id: status
                anchors.centerIn: parent
                spacing: 9
                MaterialSymbol { text: Audio.sink?.audio.muted ? "volume_off" : "volume_up"; iconSize: 18 }
                MaterialSymbol { text: Network.wifiEnabled ? "wifi" : "lan"; iconSize: 18 }
                MaterialSymbol { text: "bluetooth"; iconSize: 18 }
                StyledText { text: Battery.available ? Math.round(Battery.percentage * 100) + "%" : "AC"; font.pixelSize: 12 }
            }
            MouseArea { anchors.fill: parent; onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen }
        }
        Pill {
            implicitWidth: 34; implicitHeight: 32
            MaterialSymbol { anchors.centerIn: parent; text: "power_settings_new"; iconSize: 18 }
            MouseArea { anchors.fill: parent; onClicked: GlobalStates.sessionOpen = !GlobalStates.sessionOpen }
        }
    }
}
