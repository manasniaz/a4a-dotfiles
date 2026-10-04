pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The laptop panel's brightness. Read from the kernel's backlight device every
// second, so the brightness keys and the slider show the same real level. Written
// through brightnessctl, which has the permission the kernel wants for it.
Singleton {
    id: root

    // The panel's backlight. Per machine: `ls /sys/class/backlight` lists the names.
    readonly property string device: "intel_backlight"

    property real raw: 0
    property real max: 1
    readonly property bool present: max > 0
    readonly property real level: present ? raw / max : 0
    readonly property int percent: Math.round(level * 100)

    // Slider drags send many values in a row; only the last one is written.
    property int pending: -1

    // Never drop to zero: a black screen with no visible way back is a trap.
    readonly property real minLevel: 0.01

    function setLevel(v) {
        const clamped = Math.max(minLevel, Math.min(1, v))
        raw = Math.round(clamped * max)
        pending = raw
        writeTimer.restart()
    }

    // A fresh read, for the OSD: the background reader only runs with the island open.
    function refresh() {
        current.reload()
        maxFile.reload()
    }

    Timer {
        id: writeTimer
        interval: 60
        onTriggered: Quickshell.execDetached(["brightnessctl", "-q", "set", String(root.pending)])
    }

    // Read only while the island is open, where the brightness card is. The pill
    // doesn't show it, so there's no reason to read it in the background.
    Timer {
        interval: 1000
        running: IslandState.open
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Don't read back while a drag is still being written, or the
            // slider jumps to the previous value for a moment.
            if (!writeTimer.running) {
                current.reload()
                maxFile.reload()
            }
        }
    }

    FileView {
        id: current
        path: "/sys/class/backlight/" + root.device + "/brightness"
        printErrors: false
        onLoaded: root.raw = parseInt(current.text()) || 0
    }

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
        printErrors: false
        onLoaded: root.max = parseInt(maxFile.text()) || 1
    }
}
