// SPDX-License-Identifier: GPL-3.0-or-later
pragma Singleton
import QtQuick
import Quickshell
import "TokenData.js" as Tokens
Singleton {
    readonly property bool ember: Quickshell.env("VELDORA_ACCENT") === "ember"
    property bool reducedMotion: Quickshell.env("VELDORA_REDUCED_MOTION") === "1"
    property bool highContrast: Quickshell.env("VELDORA_HIGH_CONTRAST") === "1"
    readonly property color canvas: Tokens.colors.canvas
    readonly property color surface: Tokens.colors.surface
    readonly property color raised: Tokens.colors.raised
    readonly property color text: Tokens.colors.text
    readonly property color secondary: Tokens.colors.secondary
    readonly property color accent: ember ? Tokens.colors.ember : Tokens.colors.accent
    readonly property color border: highContrast ? Tokens.colors.secondary : Tokens.colors.border
    readonly property color critical: Tokens.colors.critical
    readonly property int duration: reducedMotion ? 0 : 200
    readonly property string font: "Noto Sans"
}
