pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The wallpaper palette, read from the file matugen writes (see matugen/).
// The fallbacks are only used before the first generation, same as hypr/colors.lua.
Singleton {
    id: root

    property color bg: "#111111"
    property color surface: "#1c1c1c"
    property color muted: "#3a3a3a"
    property color fg: "#d4d4d4"
    property color accent: "#8aa1b1"

    // Pills use the surface colour, fully opaque: any see-through shows the text
    // of windows behind them, which looks like a rendering fault.
    readonly property color pill: surface
    // Cards sit on the pill, a step lighter so they read as separate groups.
    readonly property color card: Qt.lighter(surface, 1.35)
    // Secondary text: the same hue as fg, quieter. Hierarchy comes from this and from
    // size and weight, so the bar needs no extra colours.
    readonly property color fgDim: Qt.rgba(fg.r, fg.g, fg.b, 0.62)
    // Captions: card titles, small labels. Quieter still, but readable on a card.
    readonly property color fgFaint: Qt.rgba(fg.r, fg.g, fg.b, 0.42)
    // Hairlines: pill borders and the dividers between groups.
    readonly property color line: Qt.rgba(muted.r, muted.g, muted.b, 0.55)

    // Arch Linux's brand blue. The only colour here that doesn't come from the
    // wallpaper: the logo is meant to be recognisable as Arch wherever it is.
    readonly property color arch: "#1793d1"

    FileView {
        id: colorFile
        path: Quickshell.env("HOME") + "/.cache/a4a/colors.json"
        watchChanges: true
        printErrors: false
        onLoaded: root.apply(colorFile.text())
        onFileChanged: colorFile.reload()
    }

    function apply(text) {
        try {
            const p = JSON.parse(text)
            root.bg = p.bg
            root.surface = p.surface
            root.muted = p.muted
            root.fg = p.fg
            root.accent = p.accent
        } catch (e) {
            // Keep the last good palette if the file is half-written.
        }
    }
}
