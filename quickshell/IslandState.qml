pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Shared state for the bar's two panels: whether one is open, which page it shows,
// what the bar and each home page contain, and the media player the island controls.
// A singleton so the bar, the panels, the outside-click catcher and the IPC handlers
// all see one value.
//
// Every page opens from the pill it belongs to, so a click opens things where the
// click was:
//   centre  the island: the clock, calendar, media, notifications, wallpaper, capture
//   status  the right pill, grown into the control centre: Wi-Fi, Bluetooth, sound,
//           system, network, power, and Bluetooth pairing requests
// Settings belongs to neither: it opens in whichever panel it was asked for from.
// Only one panel is open at a time. Moving to a page that lives in the other panel
// closes this one and opens that one, so a page is always in its one place.
Singleton {
    id: root

    property bool open: false
    property string view: "home"
    // Which panel is showing: "centre" or "status". Follows the page (see owner()).
    property string origin: "centre"
    // The power action waiting for a second click (see PowerView.qml).
    property string armed: ""
    // Height of the bar window including an open panel, in logical pixels.
    readonly property int barSpan: 1100

    readonly property var centreViews: ["home", "clock", "calendar", "media", "notifications", "wallpaper", "capture"]
    readonly property var statusViews: ["control", "wifi", "bluetooth", "sound", "system", "network", "power", "pairing"]

    // The panel a page lives in, or "" for one that goes wherever it's opened (Settings).
    function owner(v) {
        if (statusViews.indexOf(v) !== -1)
            return "status"
        if (centreViews.indexOf(v) !== -1)
            return "centre"
        return ""
    }

    // The front page of the panel that's showing; every back arrow leads here.
    readonly property string home: origin === "status" ? "control" : "home"

    // Pages are also set directly (`IslandState.view = "wifi"`), so the panel follows
    // the page here rather than in each caller.
    onViewChanged: {
        const o = owner(view)
        if (o !== "")
            origin = o
    }

    // Everything the bar can show, in display order, and where each one sits:
    //   left    beside the workspaces
    //   centre  the closed island, the most glanced-at things (time first)
    //   system  the right pill's quiet readings
    //   status  the right pill's glyphs: network, Bluetooth, sound, battery
    readonly property var choices: [
        { key: "title", label: "Window title", zone: "left" },
        { key: "time", label: "Time", zone: "centre" },
        { key: "date", label: "Date", zone: "centre" },
        { key: "track", label: "Track", zone: "centre" },
        { key: "cpu", label: "CPU", zone: "system" },
        { key: "ram", label: "RAM", zone: "system" },
        { key: "download", label: "Download speed", zone: "system" },
        { key: "upload", label: "Upload speed", zone: "system" },
        { key: "wifi", label: "Wi-Fi", zone: "status" },
        { key: "bluetooth", label: "Bluetooth", zone: "status" },
        { key: "volume", label: "Volume", zone: "status" },
        { key: "battery", label: "Battery", zone: "status" }
    ]

    // The shown keys that sit in one zone, in display order.
    function shownIn(zone) {
        return choices.filter(c => c.zone === zone && shown.indexOf(c.key) !== -1).map(c => c.key)
    }

    // The cards each home page can show, in display order, and which home they're on.
    readonly property var sections: [
        { key: "media", label: "Media controls", panel: "centre" },
        { key: "notifications", label: "Notifications", panel: "centre" },
        { key: "apps", label: "Apps and clipboard", panel: "centre" },
        { key: "network", label: "Wi-Fi and Bluetooth", panel: "status" },
        { key: "toggles", label: "Night light, Do not disturb", panel: "status" },
        { key: "sound", label: "Sound", panel: "status" },
        { key: "brightness", label: "Brightness", panel: "status" },
        { key: "mode", label: "Power mode", panel: "status" },
        { key: "system", label: "CPU, RAM and battery", panel: "status" },
        { key: "updates", label: "Updates", panel: "status" }
    ]

    // Which of the bar's choices are on. Empty is allowed: the island then shows
    // only the Arch mark and its name.
    property var shown: ["title", "time", "date", "track", "cpu", "ram", "wifi", "bluetooth", "volume", "battery"]
    // Which home cards are on.
    property var panel: ["media", "notifications", "apps", "network", "toggles", "sound", "brightness", "mode", "updates"]
    // 2: the bar split into zones. 3: the two home pages, with new cards. Older saved
    // choices get the new defaults added once.
    readonly property int settingsVersion: 3

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

    // Run a command and close the panel.
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

    // Open on one page, in the panel that page belongs to.
    function openTo(v) {
        view = v
        armed = ""
        open = true
    }

    // The island's own key (SUPER+I, the Arch mark): opens on the island's home, or
    // closes it. Closes the control centre too, so one key always gets back to nothing.
    function toggle() {
        if (open)
            close()
        else
            openTo("home")
    }

    // For keys that go to one page (SUPER+A, SUPER+N, SUPER+W, SUPER+X). Pressed
    // again on that page, it closes. A home key (SUPER+A) closes its panel from any of
    // its pages. Otherwise it goes to the page, moving panels if it has to.
    function toggleTo(v) {
        const o = owner(v) || origin
        const isHome = v === "home" || v === "control"
        if (open && (view === v || (isHome && origin === o)))
            close()
        else
            openTo(v)
    }

    // Back arrow, Backspace: the home of the panel that's showing.
    function back() {
        view = home
        armed = ""
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
        store.setText(JSON.stringify({ version: settingsVersion, shown: shown, panel: panel }))
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
                const version = data.version ?? 1
                if (Array.isArray(data.shown)) {
                    // "wifi_strength" was a separate option from the icon; both are now one.
                    let keys = data.shown.map(k => k === "wifi_strength" ? "wifi" : k)
                    if (version < 2)
                        keys = keys.concat(["title", "time", "date", "track", "wifi", "bluetooth", "volume", "battery"])
                    const known = root.choices.map(c => c.key)
                    root.shown = known.filter(k => keys.indexOf(k) !== -1)
                }
                if (Array.isArray(data.panel)) {
                    let keys = data.panel
                    if (version < 3)
                        keys = keys.concat(["notifications", "toggles", "mode"])
                    // Unknown keys (old cards that have gone) are dropped.
                    root.panel = root.sections.map(s => s.key).filter(k => keys.indexOf(k) !== -1)
                }
                if (version < root.settingsVersion)
                    root.save()
            } catch (e) {
                // A missing or damaged file just means the defaults.
            }
        }
    }
}
