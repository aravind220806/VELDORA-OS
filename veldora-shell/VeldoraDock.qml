import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: veldoraDock
    visible: !VeldoraState.fullscreen && !VeldoraState.privacyMode
    WlrLayershell.namespace: "veldora-dock"
    anchors.bottom: true
    color: "transparent"
    implicitWidth: Math.min(screen ? screen.width : 1280, veldoraDockRow.implicitWidth + VeldoraTokens.spacing.lg * 2 + VeldoraTokens.values.shadow.blur * 2)
    implicitHeight: VeldoraTokens.sizes.dockHeight + VeldoraTokens.sizes.dockGap + VeldoraTokens.values.shadow.blur
    exclusiveZone: VeldoraState.dockPinned ? VeldoraTokens.sizes.dockHeight : 0
    mask: Region { item: veldoraDockGlass; Region { item: veldoraReveal } }
    property int veldoraHovered: -100
    property bool veldoraRevealed: VeldoraState.dockPinned || veldoraDockHover.hovered || veldoraRevealMouse.containsMouse
    readonly property var veldoraApps: VeldoraState.dockApps
    Item {
        id: veldoraReveal
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: veldoraDockGlass.width; height: VeldoraTokens.spacing.xs
        MouseArea { id: veldoraRevealMouse; anchors.fill: parent; hoverEnabled: true }
    }
    VeldoraGlass {
        id: veldoraDockGlass
        anchors.horizontalCenter: parent.horizontalCenter
        y: veldoraDock.veldoraRevealed ? VeldoraTokens.values.shadow.blur : veldoraDock.height - VeldoraTokens.spacing.xs
        width: veldoraDock.width - VeldoraTokens.values.shadow.blur * 2
        height: VeldoraTokens.sizes.dockHeight
        Behavior on y { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack } }
        HoverHandler { id: veldoraDockHover }
        ScrollView {
            anchors.fill: parent; anchors.leftMargin: VeldoraTokens.spacing.lg; anchors.rightMargin: VeldoraTokens.spacing.lg
            contentWidth: veldoraDockRow.implicitWidth
            contentHeight: availableHeight
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        Row {
            id: veldoraDockRow
            y: (veldoraDockGlass.height - height) / 2
            spacing: VeldoraTokens.spacing.sm
            VeldoraButton {
                anchors.verticalCenter: parent.verticalCenter
                veldoraIcon: VeldoraState.dockPinned ? "keep" : "keep_off"
                veldoraSelected: VeldoraState.dockPinned
                onClicked: VeldoraState.setPreference("dockPinned", !VeldoraState.dockPinned)
                Accessible.name: "Pin dock"
            }
            Repeater {
                model: veldoraDock.veldoraApps
                delegate: Item {
                    id: veldoraDockApp
                    required property var modelData
                    required property int index
                    readonly property var veldoraWindows: modelData.windows
                    readonly property bool veldoraActive: veldoraWindows.some(w => w.activated)
                    readonly property real veldoraSize: veldoraDock.veldoraHovered === index ? VeldoraTokens.sizes.iconHover : Math.abs(veldoraDock.veldoraHovered - index) === 1 ? VeldoraTokens.sizes.iconNeighbor : VeldoraTokens.sizes.icon
                    width: veldoraSize; height: VeldoraTokens.sizes.iconHover + VeldoraTokens.spacing.sm
                    Behavior on width { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack } }
                    Rectangle {
                        width: veldoraDockApp.width; height: width
                        anchors.centerIn: parent
                        radius: VeldoraTokens.radius.pill
                        color: veldoraDockAppMouse.containsMouse ? VeldoraTokens.accentSoft : VeldoraTokens.colors.surfaceHigh
                        VeldoraAppIcon { anchors.centerIn: parent; veldoraAppId: veldoraDockApp.modelData.id; font.pixelSize: parent.width * 0.55 }
                    }
                    Rectangle {
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        width: VeldoraTokens.spacing.xs; height: width; radius: width / 2
                        visible: veldoraDockApp.veldoraWindows.length > 0
                        color: veldoraDockApp.veldoraActive ? VeldoraTokens.colors.accent : VeldoraTokens.colors.textDim
                    }
                    ToolTip.visible: veldoraDockAppMouse.containsMouse
                    ToolTip.text: modelData.name
                    ToolTip.delay: 400
                    MouseArea {
                        id: veldoraDockAppMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onEntered: veldoraDock.veldoraHovered = veldoraDockApp.index
                        onExited: veldoraDock.veldoraHovered = -100
                        onClicked: VeldoraState.dockActivate(veldoraDockApp.modelData.id)
                    }
                }
            }
            Rectangle { width: 2; height: VeldoraTokens.sizes.close; radius: VeldoraTokens.radius.pill; color: VeldoraTokens.border; anchors.verticalCenter: parent.verticalCenter }
            VeldoraButton { anchors.verticalCenter: parent.verticalCenter; veldoraIcon: "apps"; onClicked: VeldoraState.toggleLauncher(); Accessible.name: "Open applications" }
        }
        }
    }
}
