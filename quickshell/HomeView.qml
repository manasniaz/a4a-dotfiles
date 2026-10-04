import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking

// The island's front page: quick cards for Wi-Fi and Bluetooth, then the groups
// you've chosen in Settings. Each group is a card, so the spacing and the
// alignment are the same everywhere.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var player: IslandState.player

    readonly property var wifiNet: wifi ? wifi.networks.values.find(n => n.connected) ?? null : null

    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        visible: IslandState.inPanel("network") || IslandState.inPanel("bluetooth")

        QuickCard {
            visible: IslandState.inPanel("network")
            title: "Wi-Fi"
            on: Networking.wifiEnabled
            status: !Networking.wifiEnabled ? "Off"
                : (root.wifiNet ? root.wifiNet.name + " · " + Stats.wifiPercent + "%" : "Not connected")
            onOpened: IslandState.view = "wifi"
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        QuickCard {
            visible: IslandState.inPanel("bluetooth")
            title: "Bluetooth"
            on: Bluetooth.defaultAdapter !== null && Bluetooth.defaultAdapter.enabled
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

    Card {
        visible: IslandState.inPanel("media") && root.player !== null
        title: "Now playing"

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: IslandState.trackTitle(root.player)
                    color: Theme.fg
                    font.pixelSize: 13
                }

                // The app that's playing, so a browser's own status line is clear.
                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.player ? root.player.identity : ""
                    color: Theme.muted
                    font.pixelSize: 11
                }
            }

            Tile { label: "⏮"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.previous() }
            Tile { label: root.player && root.player.isPlaying ? "⏸" : "▶"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.togglePlaying() }
            Tile { label: "⏭"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.next() }
        }
    }

    Card {
        visible: IslandState.inPanel("apps")
        title: "Launch"

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 6
            columnSpacing: 6

            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Apps"
                onActivated: IslandState.run(["wofi", "--show", "drun"])
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Clipboard"
                onActivated: IslandState.run(["sh", "-c", "cliphist list | wofi --dmenu | cliphist decode | wl-copy"])
            }
        }
    }

    Card {
        visible: IslandState.inPanel("sound")
        title: "Sound"

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Tile {
                implicitWidth: 40
                implicitHeight: 34
                onActivated: Volume.toggleMute()

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
            }
        }
    }

    UpdatesCard {
        visible: IslandState.inPanel("updates")
    }

    Card {
        visible: IslandState.inPanel("system")
        title: "System"

        SystemStats {}
        Battery {}
    }
}
