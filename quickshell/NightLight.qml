pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The night light: warm the screen between 20:00 and 07:00, with hyprsunset. The switch
// is saved in the state folder, so it survives a restart. The time is checked once a
// minute, and only while the schedule is on.
Singleton {
    id: root

    readonly property int warmKelvin: 3500
    readonly property int warmFrom: 20
    readonly property int warmUntil: 7

    property bool enabled: false
    // A function, not a binding: the time has to be read each time it's asked.
    function warmNow() {
        const h = new Date().getHours()
        return h >= warmFrom || h < warmUntil
    }

    function setEnabled(on) {
        enabled = on
        store.setText(on ? "on" : "off")
        apply()
    }

    // Tells hyprsunset what to do: a warm temperature while it's the night hours,
    // otherwise no filter at all.
    function apply() {
        if (enabled && warmNow())
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(warmKelvin)])
        else
            Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"])
    }

    Timer {
        interval: 60 * 1000
        running: root.enabled
        repeat: true
        onTriggered: root.apply()
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.local/state/a4a/nightlight"
        printErrors: false
        onLoaded: {
            root.enabled = store.text().trim() === "on"
            root.apply()
        }
    }
}
