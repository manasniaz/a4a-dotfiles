pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Shared state for the centre island: whether it is open, which view it shows,
// what the closed pill and the home view contain, and the media player it
// controls. A singleton so the bar, the island, the outside-click catcher and
// the IPC handler all see one value.
Singleton {
    id: root

    property bool open: false
    // "home", "wifi", "bluetooth", "calendar", "clock", "media", "network", "sound",
    // "system", "settings", "wallpaper", "power", "capture" or "notifications".
    property string view: "home"
    // The power action waiting for a second click (see IslandPanel.qml).
    property string armed: ""
    // Height of the bar window including the open island, in logical pixels.
    readonly property int barSpan: 1100

    // Everything the closed island can show, in display order.
    readonly property var choices: [
        { key: "time", label: "Time" },
        { key: "date", label: "Date" },
        { key: "track", label: "Track" },
        { key: "cpu", label: "CPU" },
        { key: "ram", label: "RAM" },
        { key: "battery", label: "Battery" },
        { key: "wifi", label: "Wi-Fi (icon and signal %)" },
        { key: "bluetooth", label: "Bluetooth icon" },
        { key: "download", label: "Download speed" },
        { key: "upload", label: "Upload speed" },
        { key: "volume", label: "Volume" }
    ]

    // The sections the home view can show, in display order.
    readonly property var sections: [
        { key: "network", label: "Wi-Fi card" },
        { key: "bluetooth", label: "Bluetooth card" },
        { key: "media", label: "Media controls" },
        { key: "apps", label: "Apps and clipboard" },
        { key: "sound", label: "Sound card" },
        { key: "brightness", label: "Brightness card" },
        { key: "system", label: "CPU, RAM and battery" },
        { key: "updates", label: "Updates card" },
    ]

    // Which of the closed-pill choices are on. Empty is allowed: the pill then
    // shows only the Arch mark and its name.
    property var shown: ["time"]
    // Which home sections are on.
    property var panel: ["network", "bluetooth", "media", "sound", "brightness", "apps", "updates"]

    // The player the island controls: the one playing, else the first one.
    readonly property var player: {
        const list = Mpris.players.values
        return list.find(p => p.isPlaying) ?? list[0] ?? null
    }

    // What a track line reads as. Players often leave the artist empty, and some
    // (browsers) put their own status text in the title, so the app's name is shown
    // alongside it and used on its own when there's no title.
    function trackTitle(p) {
        if (!p)
            return ""
        const parts = [p.trackArtist, p.trackTitle].filter(s => s)
        return parts.length > 0 ? parts.join(" – ") : p.identity
    }

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/a4a"

    // Run a command and close the island.
    function run(cmd) {
        Quickshell.execDetached(cmd)
        close()
    }

    // Every way of closing goes through here (the ✕, a click outside, Escape),
    // so nothing is left armed for the next time it opens.
    function close() {
        open = false
        armed = ""
    }

    // Open the island on a particular screen, from a click on the closed pill.
    function openTo(v) {
        view = v
        armed = ""
        open = true
    }

    // Opening always starts on the home view, wherever it was closed from.
    function toggle() {
        if (open) {
            close()
        } else {
            view = "home"
            armed = ""
            open = true
        }
    }

    function isShown(key) {
        return shown.indexOf(key) !== -1
    }

    function inPanel(key) {
        return panel.indexOf(key) !== -1
    }

    function toggleShown(key) {
        const next = isShown(key) ? shown.filter(k => k !== key) : shown.concat([key])
        // Keep the display order fixed, whatever order things were picked in.
        shown = choices.map(c => c.key).filter(k => next.indexOf(k) !== -1)
        save()
    }

    function togglePanel(key) {
        const next = inPanel(key) ? panel.filter(k => k !== key) : panel.concat([key])
        panel = sections.map(s => s.key).filter(k => next.indexOf(k) !== -1)
        save()
    }

    function save() {
        store.setText(JSON.stringify({ shown: shown, panel: panel }))
    }

    Timer {
        interval: 1
        running: true
        onTriggered: Quickshell.execDetached(["mkdir", "-p", root.stateDir])
    }

    FileView {
        id: store
        path: root.stateDir + "/island.json"
        printErrors: false
        onLoaded: {
            try {
                const data = JSON.parse(store.text())
                if (Array.isArray(data.shown))
                    // "wifi_strength" was a separate option from the icon; both are now one.
                    root.shown = data.shown.map(k => k === "wifi_strength" ? "wifi" : k)
                                           .filter((k, i, all) => all.indexOf(k) === i)
                if (Array.isArray(data.panel))
                    root.panel = data.panel
            } catch (e) {
                // A missing or damaged file just means the defaults.
            }
        }
    }
}
