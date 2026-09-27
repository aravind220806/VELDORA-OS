import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: veldoraSport
    visible: VeldoraState.sportOpen || veldoraSportCard.opacity > 0
    WlrLayershell.namespace: "veldora-sport"
    WlrLayershell.keyboardFocus: VeldoraState.sportOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors { top: true; left: true }
    margins { top: VeldoraTokens.sizes.bar + VeldoraTokens.spacing.sm; left: VeldoraTokens.sizes.barGap }
    implicitWidth: 660 + VeldoraTokens.values.shadow.blur * 2
    implicitHeight: veldoraSportColumn.implicitHeight + VeldoraTokens.spacing.md * 2 + VeldoraTokens.values.shadow.blur * 2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region { item: veldoraSportCard }

    VeldoraGlass {
        id: veldoraSportCard
        anchors.fill: parent
        anchors.margins: VeldoraTokens.values.shadow.blur
        radius: VeldoraTokens.radius.card
        opacity: VeldoraState.sportOpen ? 1 : 0
        scale: VeldoraState.sportOpen ? 1 : 0.92
        transformOrigin: Item.TopLeft
        Behavior on opacity { NumberAnimation { duration: VeldoraTokens.duration } }
        Behavior on scale { NumberAnimation { duration: VeldoraTokens.duration; easing.type: Easing.OutBack; easing.overshoot: VeldoraTokens.values.animation.overshoot } }
        focus: VeldoraState.sportOpen
        Keys.onEscapePressed: VeldoraState.sportOpen = false

        // Subtle carbon weave pattern overlay
        Image {
            anchors.fill: parent
            anchors.margins: VeldoraTokens.spacing.sm
            source: Qt.resolvedUrl("veldora-scales.svg")
            fillMode: Image.Tile
            opacity: VeldoraTokens.values.effects.patternOpacity * 1.5
        }

        ColumnLayout {
            id: veldoraSportColumn
            anchors.fill: parent
            anchors.margins: VeldoraTokens.spacing.md
            spacing: VeldoraTokens.spacing.md

            // BMW M Sport Header
            RowLayout {
                Layout.fillWidth: true
                spacing: VeldoraTokens.spacing.sm

                // Slanted M stripes
                Row {
                    spacing: 4
                    Rectangle { width: 5; height: 22; color: "#0066B1"; transform: Rotation { origin.x: 2; origin.y: 11; angle: -15 } }
                    Rectangle { width: 5; height: 22; color: "#001E4F"; transform: Rotation { origin.x: 2; origin.y: 11; angle: -15 } }
                    Rectangle { width: 5; height: 22; color: "#FF3B30"; transform: Rotation { origin.x: 2; origin.y: 11; angle: -15 } }
                }

                Column {
                    Layout.fillWidth: true
                    Row {
                        spacing: VeldoraTokens.spacing.sm
                        VeldoraText {
                            text: "/// SPORT MODE"
                            font.pixelSize: VeldoraTokens.font.heading
                            font.bold: true
                            font.italic: true
                            color: "#FF3B30"
                        }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 68; height: 20
                            radius: VeldoraTokens.radius.pill
                            color: "#33FF3B30"
                            border.width: 1
                            border.color: "#FF3B30"
                            VeldoraText {
                                anchors.centerIn: parent
                                text: "SPORT+"
                                font.pixelSize: 10
                                font.bold: true
                                color: "#FF3B30"
                            }
                        }
                    }
                    VeldoraText {
                        text: "PERFORMANCE TELEMETRY · LIVE INSTRUMENT CLUSTER"
                        font.pixelSize: VeldoraTokens.font.small
                        color: VeldoraTokens.colors.textDim
                        font.letterSpacing: 1.2
                    }
                }

                VeldoraButton {
                    width: VeldoraTokens.sizes.close
                    height: width
                    veldoraIcon: "close"
                    veldoraFilled: true
                    onClicked: VeldoraState.sportOpen = false
                    Accessible.name: "Close Sport Mode"
                }
            }

            // Dual Speedometer & Tachometer Dials
            RowLayout {
                Layout.fillWidth: true
                spacing: VeldoraTokens.spacing.lg

                // LEFT GAUGE: GPU SPEEDOMETER
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 200

                    readonly property real gpuMhz: {
                        const str = VeldoraState.hardware.gpu || "";
                        const val = parseFloat(str);
                        if (isNaN(val)) return 300;
                        return str.indexOf("GHz") !== -1 ? val * 1000 : val;
                    }
                    readonly property real normGpu: Math.min(1.0, Math.max(0.0, gpuMhz / 2500))

                    Canvas {
                        id: gpuCanvas
                        anchors.fill: parent
                        renderTarget: Canvas.FramebufferObject

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            const cx = width / 2;
                            const cy = height / 2 + 10;
                            const r = 75;

                            // Background Track
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, -Math.PI * 1.25, Math.PI * 0.25);
                            ctx.lineWidth = 10;
                            ctx.strokeStyle = "#25252D";
                            ctx.lineCap = "round";
                            ctx.stroke();

                            // Active Arc
                            const currentAngle = -Math.PI * 1.25 + parent.normGpu * (Math.PI * 1.5);
                            if (parent.normGpu > 0.01) {
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, -Math.PI * 1.25, currentAngle);
                                ctx.lineWidth = 10;
                                ctx.strokeStyle = "#FF3B30";
                                ctx.lineCap = "round";
                                ctx.stroke();
                            }

                            // Sport Ticks
                            for (let i = 0; i <= 10; i++) {
                                const angle = -Math.PI * 1.25 + (i / 10) * (Math.PI * 1.5);
                                const innerR = (i % 2 === 0) ? r - 18 : r - 12;
                                const outerR = r - 7;
                                ctx.beginPath();
                                ctx.moveTo(cx + Math.cos(angle) * innerR, cy + Math.sin(angle) * innerR);
                                ctx.lineTo(cx + Math.cos(angle) * outerR, cy + Math.sin(angle) * outerR);
                                ctx.lineWidth = (i % 2 === 0) ? 2 : 1;
                                ctx.strokeStyle = (i >= 8) ? "#FF3B30" : "#888892";
                                ctx.stroke();
                            }

                            // Needle
                            ctx.beginPath();
                            ctx.moveTo(cx, cy);
                            ctx.lineTo(cx + Math.cos(currentAngle) * (r - 12), cy + Math.sin(currentAngle) * (r - 12));
                            ctx.lineWidth = 3;
                            ctx.strokeStyle = "#FF453A";
                            ctx.stroke();

                            // Hub
                            ctx.beginPath();
                            ctx.arc(cx, cy, 7, 0, Math.PI * 2);
                            ctx.fillStyle = "#FF3B30";
                            ctx.fill();

                            ctx.beginPath();
                            ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                            ctx.fillStyle = "#FFFFFF";
                            ctx.fill();
                        }

                        Connections {
                            target: parent
                            function onNormGpuChanged() { gpuCanvas.requestPaint(); }
                        }
                        Component.onCompleted: requestPaint()
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height / 2 - 38
                        spacing: 0
                        VeldoraText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(parent.parent.gpuMhz)
                            font.pixelSize: 28
                            font.bold: true
                            font.italic: true
                            color: "#FFFFFF"
                        }
                        VeldoraText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "MHz SPEED"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#FF3B30"
                        }
                    }

                    VeldoraText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "GPU CLOCK GAUGE"
                        font.pixelSize: 11
                        font.bold: true
                        color: VeldoraTokens.colors.textDim
                        font.letterSpacing: 1.0
                    }
                }

                // RIGHT GAUGE: CPU TACHOMETER
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 200

                    readonly property real cpuVal: {
                        const val = parseFloat(VeldoraState.hardware.cpu);
                        return isNaN(val) ? 6 : val;
                    }
                    readonly property real normCpu: Math.min(1.0, Math.max(0.0, cpuVal / 100))

                    Canvas {
                        id: cpuCanvas
                        anchors.fill: parent
                        renderTarget: Canvas.FramebufferObject

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            const cx = width / 2;
                            const cy = height / 2 + 10;
                            const r = 75;

                            // Background Track
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, -Math.PI * 1.25, Math.PI * 0.25);
                            ctx.lineWidth = 10;
                            ctx.strokeStyle = "#25252D";
                            ctx.lineCap = "round";
                            ctx.stroke();

                            // Redline track section (top 20%)
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, -Math.PI * 1.25 + 0.8 * (Math.PI * 1.5), Math.PI * 0.25);
                            ctx.lineWidth = 10;
                            ctx.strokeStyle = "#4D1115";
                            ctx.lineCap = "round";
                            ctx.stroke();

                            // Active Arc
                            const currentAngle = -Math.PI * 1.25 + parent.normCpu * (Math.PI * 1.5);
                            if (parent.normCpu > 0.01) {
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, -Math.PI * 1.25, currentAngle);
                                ctx.lineWidth = 10;
                                ctx.strokeStyle = parent.normCpu >= 0.8 ? "#FF2200" : "#FF6B6B";
                                ctx.lineCap = "round";
                                ctx.stroke();
                            }

                            // Ticks (RPM style 0 to 10)
                            for (let i = 0; i <= 10; i++) {
                                const angle = -Math.PI * 1.25 + (i / 10) * (Math.PI * 1.5);
                                const isRedline = i >= 8;
                                const innerR = (i % 2 === 0) ? r - 18 : r - 12;
                                const outerR = r - 7;
                                ctx.beginPath();
                                ctx.moveTo(cx + Math.cos(angle) * innerR, cy + Math.sin(angle) * innerR);
                                ctx.lineTo(cx + Math.cos(angle) * outerR, cy + Math.sin(angle) * outerR);
                                ctx.lineWidth = (i % 2 === 0) ? 2 : 1;
                                ctx.strokeStyle = isRedline ? "#FF3B30" : "#888892";
                                ctx.stroke();
                            }

                            // Needle
                            ctx.beginPath();
                            ctx.moveTo(cx, cy);
                            ctx.lineTo(cx + Math.cos(currentAngle) * (r - 12), cy + Math.sin(currentAngle) * (r - 12));
                            ctx.lineWidth = 3;
                            ctx.strokeStyle = "#FF3B30";
                            ctx.stroke();

                            // Hub
                            ctx.beginPath();
                            ctx.arc(cx, cy, 7, 0, Math.PI * 2);
                            ctx.fillStyle = "#FF3B30";
                            ctx.fill();

                            ctx.beginPath();
                            ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                            ctx.fillStyle = "#FFFFFF";
                            ctx.fill();
                        }

                        Connections {
                            target: parent
                            function onNormCpuChanged() { cpuCanvas.requestPaint(); }
                        }
                        Component.onCompleted: requestPaint()
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height / 2 - 38
                        spacing: 0
                        VeldoraText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(parent.parent.cpuVal) + "%"
                            font.pixelSize: 28
                            font.bold: true
                            font.italic: true
                            color: "#FFFFFF"
                        }
                        VeldoraText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "CPU LOAD"
                            font.pixelSize: 10
                            font.bold: true
                            color: parent.parent.normCpu >= 0.8 ? "#FF2200" : "#FF6B6B"
                        }
                    }

                    VeldoraText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "TACHOMETER / ENGINE"
                        font.pixelSize: 11
                        font.bold: true
                        color: VeldoraTokens.colors.textDim
                        font.letterSpacing: 1.0
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: VeldoraTokens.border
            }

            // Telemetry Bars: RAM, SWAP, STORAGE, VITALS
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: VeldoraTokens.spacing.md
                rowSpacing: VeldoraTokens.spacing.sm

                // RAM Telemetry Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: VeldoraTokens.radius.tile
                    color: VeldoraTokens.colors.surfaceHigh

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VeldoraTokens.spacing.sm
                        RowLayout {
                            VeldoraIcon { text: "developer_board"; color: "#FF6B6B"; font.pixelSize: 16 }
                            VeldoraText { text: "RAM BOOST"; font.bold: true; font.pixelSize: 12; Layout.fillWidth: true }
                            VeldoraText { text: VeldoraState.hardware.ram; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 6; radius: 3; color: "#25252E"
                            Rectangle {
                                width: Math.max(8, parent.width * Math.min(1.0, (parseFloat(VeldoraState.hardware.ram) || 4.0) / 16.0))
                                height: parent.height; radius: 3
                                color: "#FF6B6B"
                            }
                        }
                    }
                }

                // SWAP Telemetry Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: VeldoraTokens.radius.tile
                    color: VeldoraTokens.colors.surfaceHigh

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VeldoraTokens.spacing.sm
                        RowLayout {
                            VeldoraIcon { text: "swap_horiz"; color: "#FF8A8F"; font.pixelSize: 16 }
                            VeldoraText { text: "SWAP PRESSURE"; font.bold: true; font.pixelSize: 12; Layout.fillWidth: true }
                            VeldoraText { text: VeldoraState.hardware.swap; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 6; radius: 3; color: "#25252E"
                            Rectangle {
                                width: Math.max(4, parent.width * Math.min(1.0, (parseFloat(VeldoraState.hardware.swap) || 0) / 100))
                                height: parent.height; radius: 3
                                color: "#FF8A8F"
                            }
                        }
                    }
                }

                // DISK Telemetry Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: VeldoraTokens.radius.tile
                    color: VeldoraTokens.colors.surfaceHigh

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VeldoraTokens.spacing.sm
                        RowLayout {
                            VeldoraIcon { text: "storage"; color: "#FF9E79"; font.pixelSize: 16 }
                            VeldoraText { text: "NVMe STORAGE"; font.bold: true; font.pixelSize: 12; Layout.fillWidth: true }
                            VeldoraText { text: VeldoraState.hardware.storage + " USED"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 6; radius: 3; color: "#25252E"
                            Rectangle {
                                width: Math.max(8, parent.width * Math.min(1.0, (parseFloat(VeldoraState.hardware.storage) || 23) / 100))
                                height: parent.height; radius: 3
                                color: "#FF9E79"
                            }
                        }
                    }
                }

                // SYSTEM VITALS Telemetry Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: VeldoraTokens.radius.tile
                    color: VeldoraTokens.colors.surfaceHigh

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VeldoraTokens.spacing.sm
                        RowLayout {
                            VeldoraIcon { text: "bolt"; color: "#FFD60A"; font.pixelSize: 16 }
                            VeldoraText { text: "SYSTEM VITALS"; font.bold: true; font.pixelSize: 12; Layout.fillWidth: true }
                            VeldoraText {
                                text: VeldoraState.hardware.battery >= 0 ? VeldoraState.hardware.battery + "% " + (VeldoraState.hardware.charging ? "CHG" : "BAT") : "AC POWER"
                                font.bold: true; font.pixelSize: 13; color: "#FFFFFF"
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            VeldoraText {
                                text: "LINK: " + (VeldoraState.hardware.network !== "Disconnected" ? VeldoraState.hardware.network : "ONLINE")
                                font.pixelSize: 11; color: VeldoraTokens.colors.textDim; elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            VeldoraText { text: "M DYNAMICS"; font.bold: true; font.pixelSize: 10; color: "#FF3B30" }
                        }
                    }
                }
            }
        }
    }
}
