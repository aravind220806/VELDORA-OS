import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: veldoraSplash
    WlrLayershell.namespace: "veldora-splash"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: !bootComplete && Quickshell.env("VELDORA_ISOLATED") !== "1"

    property real progress: 0.0
    property bool bootComplete: false

    Item {
        id: splashCard
        anchors.fill: parent
        opacity: veldoraSplash.visible ? 1.0 : 0.0

        // Solid dark backdrop
        Rectangle {
            anchors.fill: parent
            color: "#08080A"
        }

        // Splash animation sequence
        SequentialAnimation {
            running: veldoraSplash.visible
            // 1. Initial engine ignite & emblem glow
            ParallelAnimation {
                NumberAnimation { target: splashEmblem; property: "scale"; from: 0.82; to: 1.0; duration: 1200; easing.type: Easing.OutCubic }
                NumberAnimation { target: splashEmblem; property: "opacity"; from: 0.0; to: 1.0; duration: 800 }
                NumberAnimation { target: haloRing; property: "scale"; from: 0.7; to: 1.25; duration: 1400; easing.type: Easing.OutQuad }
                NumberAnimation { target: haloRing; property: "opacity"; from: 0.8; to: 0.0; duration: 1400 }
            }
            // 2. Progress fill matching engine rev up
            NumberAnimation { target: veldoraSplash; property: "progress"; from: 0.0; to: 1.0; duration: 2200; easing.type: Easing.InOutCubic }
            // 3. System ready hold
            PauseAnimation { duration: 400 }
            // 4. Smooth reveal to desktop
            NumberAnimation { target: splashCard; property: "opacity"; to: 0.0; duration: 600; easing.type: Easing.OutQuad }
            ScriptAction { script: veldoraSplash.bootComplete = true }
        }

    // Subtle carbon weave background pattern
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("veldora-scales.svg")
        fillMode: Image.Tile
        opacity: 0.04
    }

    // Central BMW M Performance Cluster
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // Emblem with holographic halo ring
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 140
            height: 140

            // Glowing pulse ring
            Rectangle {
                id: haloRing
                anchors.centerIn: parent
                width: 150
                height: 150
                radius: 75
                color: "transparent"
                border.width: 3
                border.color: "#00E5FF"
            }

            // BMW Roundel Logo
            Image {
                id: splashEmblem
                anchors.fill: parent
                source: Qt.resolvedUrl("bmw-emblem.svg")
                sourceSize.width: 140
                sourceSize.height: 140
            }
        }

        // Slanted ///M Tricolor Stripes
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6
            Rectangle { width: 7; height: 26; color: "#0066B1"; transform: Rotation { origin.x: 3; origin.y: 13; angle: -18 } }
            Rectangle { width: 7; height: 26; color: "#001E4F"; transform: Rotation { origin.x: 3; origin.y: 13; angle: -18 } }
            Rectangle { width: 7; height: 26; color: "#FF3B30"; transform: Rotation { origin.x: 3; origin.y: 13; angle: -18 } }
        }

        // Branding Typography
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            VeldoraText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "BMW M8 COMPETITION OS"
                font.pixelSize: 22
                font.bold: true
                font.italic: true
                font.letterSpacing: 2.0
                color: "#FFFFFF"
            }
            VeldoraText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "4.4L V8 TWIN-TURBO · TELEMETRY ENGINE READY"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.5
                color: "#FF3B30"
            }
        }

        // Digital HUD Telemetry Loading Bar
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Rectangle {
                width: 280
                height: 8
                radius: 4
                color: "#18181E"
                border.width: 1
                border.color: "#282834"

                Rectangle {
                    width: parent.width * veldoraSplash.progress
                    height: parent.height
                    radius: 4
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#00E5FF" }
                        GradientStop { position: 0.6; color: "#FFD60A" }
                        GradientStop { position: 1.0; color: "#FF3B30" }
                    }
                }
            }

            RowLayout {
                width: 280
                VeldoraText {
                    text: veldoraSplash.progress < 0.4 ? "CHECKING SYSTEM VITALS..." : (veldoraSplash.progress < 0.85 ? "M8 IGNITION · TWIN TURBO ACTIVE" : "SYSTEM READY · ENGAGE DRIVE")
                    font.pixelSize: 10
                    font.bold: true
                    color: "#888892"
                    Layout.fillWidth: true
                }
                VeldoraText {
                    text: Math.round(veldoraSplash.progress * 100) + "%"
                    font.pixelSize: 10
                    font.bold: true
                    color: "#FFFFFF"
                }
            }
        }
    }
}
}

