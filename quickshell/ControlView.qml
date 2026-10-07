import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking

// The control centre: the right pill, opened. Everything about the machine, next to
// the readings it shows when closed. Each closed item opens its own page here, and
// a click between them (or SUPER+A) opens this front page. Which cards show is set
// in Settings.
//
// Keys: W Wi-Fi, B Bluetooth, S sound, P power, Y system, I the island. Escape closes.
ColumnLayout {
    id: root

    spacing: 10

    function handleKey(event) {
        const pages = {
            [Qt.Key_W]: "wifi", [Qt.Key_B]: "bluetooth", [Qt.Key_S]: "sound",
            [Qt.Key_P]: "power", [Qt.Key_Y]: "system", [Qt.Key_I]: "home"
        }
        const page = pages[event.key]
        if (page === undefined || event.modifiers !== Qt.NoModifier)
            return false
        IslandState.view = page
        return true
    }

    readonly property var battery: Stats.battery
    readonly property bool hasBattery: Stats.batteryPresent

    // "1 h 20 min", "35 min": UPower's estimate, in seconds.
    function duration(s) {
        const m = Math.round(s / 60)
        if (m < 60)
            return m + " min"
        return Math.floor(m / 60) + " h " + (m % 60 > 0 ? (m % 60) + " min" : "")
    }

    readonly property string batteryLine: {
        if (!hasBattery)
            return "On mains power"
        if (Stats.charging)
            return battery.timeToFull > 0 ? "Charging · full in " + duration(battery.timeToFull) : "Charging"
        if (battery.timeToEmpty > 0)
            return duration(battery.timeToEmpty) + " left"
        return "Plugged in"
    }

    // Header: the battery, the most asked-about thing here, then settings, power, close.
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Icon {
            visible: root.hasBattery
            kind: "battery"
            value: root.hasBattery ? root.battery.percentage : 0
            charging: Stats.charging
            color: Stats.charging ? Theme.accent : Theme.fg
            font.pixelSize: 26
        }

        ColumnLayout {
            spacing: 0

            Text {
                text: root.hasBattery ? Math.round(root.battery.percentage * 100) + "%" : "Control centre"
                color: Theme.fg
                font.pixelSize: root.hasBattery ? 22 : 17
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }

            Text {
                text: root.batteryLine
                color: Theme.fgDim
                font.pixelSize: 11
            }
        }

        Item { Layout.fillWidth: true }

        Tile { icon: "cog"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.view = "settings" }
        Tile { icon: "power"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.view = "power" }
        Tile { icon: "close"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.close() }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        visible: IslandState.inPanel("network")

        readonly property var wifiNet: Stats.wifiNet

        QuickCard {
            Layout.preferredWidth: 1
            title: "Wi-Fi"
            on: Networking.wifiEnabled
            status: !Networking.wifiEnabled ? "Off"
                : (Stats.wifiNet ? Stats.wifiNet.name + " · " + Stats.wifiPercent + "%" : "Not connected")
            onOpened: IslandState.view = "wifi"
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        QuickCard {
            Layout.preferredWidth: 1
            title: "Bluetooth"
            on: Stats.btOn
            status: {
                const a = Bluetooth.defaultAdapter
                if (!a) return "No adapter"
                if (!a.enabled) return "Off"
                const linked = a.devices.values.filter(d => d.connected)
                return linked.length > 0 ? linked.map(d => d.name).join(", ") : "On"
            }
            onOpened: IslandState.view = "bluetooth"
            onToggled: {
                const a = Bluetooth.defaultAdapter
                if (a) a.enabled = !a.enabled
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        visible: IslandState.inPanel("toggles")

        QuickCard {
            Layout.preferredWidth: 1
            title: "Night light"
            on: NightLight.enabled
            status: !NightLight.enabled ? "Off"
                : (NightLight.warmNow() ? "Warm now" : "From " + String(NightLight.warmFrom).padStart(2, "0") + ":00")
            onOpened: NightLight.setEnabled(!NightLight.enabled)
            onToggled: NightLight.setEnabled(!NightLight.enabled)
        }

        // Do not disturb: dunst holds new popups until it's off again, and they land in
        // the notification centre as usual. Read when this page opens.
        QuickCard {
            id: dnd
            Layout.preferredWidth: 1
            property bool paused: false
            title: "Do not disturb"
            on: paused
            status: paused ? "Popups held" : "Off"
            onOpened: toggle()
            onToggled: toggle()
            function toggle() {
                paused = !paused
                Quickshell.execDetached(["dunstctl", "set-paused", paused ? "true" : "false"])
            }

            Process {
                command: ["dunstctl", "is-paused"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: dnd.paused = text.trim() === "true"
                }
            }
        }
    }

    Card {
        visible: IslandState.inPanel("sound")
        title: Volume.sink ? "Sound · " + Volume.label(Volume.sink) : "Sound"

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Tile {
                implicitWidth: 40
                implicitHeight: 34
                onActivated: Volume.toggleMute()

                // Drawn here rather than with Tile's `icon`, which can't show the level.
                Icon {
                    anchors.centerIn: parent
                    kind: "volume"
                    value: Volume.volume
                    muted: Volume.muted
                    font.pixelSize: 16
                    color: Theme.fg
                }
            }

            Slider {
                Layout.fillWidth: true
                value: Volume.volume
                onMoved: (v) => Volume.setVolume(v)
            }

            Text {
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
                text: Volume.percent + "%"
                color: Theme.fg
                font.pixelSize: 13
                font.features: { "tnum": 1 }
            }
        }
    }

    Card {
        visible: IslandState.inPanel("brightness") && Brightness.present
        title: "Brightness"

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Icon {
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
                kind: "brightness"
                font.pixelSize: 16
                color: Theme.fg
            }

            Slider {
                Layout.fillWidth: true
                value: Brightness.level
                onMoved: (v) => Brightness.setLevel(v)
            }

            Text {
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
                text: Brightness.percent + "%"
                color: Theme.fg
                font.pixelSize: 13
                font.features: { "tnum": 1 }
            }
        }
    }

    // Power mode: power-profiles-daemon, read when this page opens. No polling.
    Card {
        id: mode
        visible: IslandState.inPanel("mode")
        title: "Power mode"

        property string profile: ""

        function set(name) {
            Quickshell.execDetached(["powerprofilesctl", "set", name])
            profile = name
        }

        Process {
            command: ["powerprofilesctl", "get"]
            running: mode.visible
            stdout: StdioCollector {
                onStreamFinished: mode.profile = text.trim()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { key: "power-saver", label: "Saver" },
                    { key: "balanced", label: "Balanced" },
                    { key: "performance", label: "Performance" }
                ]

                Tile {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 34
                    label: modelData.label
                    armed: mode.profile === modelData.key
                    onActivated: mode.set(modelData.key)
                }
            }
        }
    }

    Card {
        visible: IslandState.inPanel("system")
        title: "System"

        // The battery is the header's headline, so only CPU and RAM here.
        SystemStats {
            Layout.fillWidth: true
        }
    }

    UpdatesCard {
        visible: IslandState.inPanel("updates")
    }
}
