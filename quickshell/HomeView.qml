import QtQuick
import QtQuick.Layouts
import Quickshell

// The island's front page: the personal things. The clock, what's playing, what's
// been said (notifications), and launching. System controls live in the control
// centre, under the right pill. Which cards show is set in Settings.
//
// Keys: N notifications, W wallpaper, C capture, S settings, M media, T clock,
// D calendar, A the control centre. Escape closes.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var player: IslandState.player

    function handleKey(event) {
        const pages = {
            [Qt.Key_N]: "notifications", [Qt.Key_W]: "wallpaper", [Qt.Key_C]: "capture",
            [Qt.Key_S]: "settings", [Qt.Key_M]: "media", [Qt.Key_T]: "clock",
            [Qt.Key_D]: "calendar", [Qt.Key_A]: "control"
        }
        const page = pages[event.key]
        if (page === undefined || event.modifiers !== Qt.NoModifier)
            return false
        IslandState.view = page
        return true
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        ColumnLayout {
            spacing: 0

            Text {
                text: Qt.formatTime(clock.date, "HH:mm")
                color: Theme.fg
                font.pixelSize: 26
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }

            Text {
                text: Qt.formatDate(clock.date, "dddd, d MMMM")
                color: Theme.fgDim
                font.pixelSize: 11
            }
        }

        Item { Layout.fillWidth: true }

        Tile { icon: "image"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.view = "wallpaper" }
        Tile { icon: "camera"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.view = "capture" }
        Tile { icon: "cog"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.view = "settings" }
        Tile { icon: "close"; implicitWidth: 36; implicitHeight: 36; onActivated: IslandState.close() }
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
                    color: Theme.fgFaint
                    font.pixelSize: 11
                }
            }

            Tile { icon: "prev"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.previous() }
            Tile { icon: root.player && root.player.isPlaying ? "pause" : "play"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.togglePlaying() }
            Tile { icon: "next"; implicitWidth: 40; implicitHeight: 32; onActivated: root.player.next() }
        }
    }

    Card {
        visible: IslandState.inPanel("notifications")
        title: notes.count > 0 ? "Notifications · " + notes.count : "Notifications"

        NotificationList {
            id: notes
            limit: 3
        }

        RowLayout {
            visible: notes.count > 0
            Layout.fillWidth: true
            spacing: 6

            Tile {
                Layout.fillWidth: true
                implicitHeight: 32
                label: notes.count > 3 ? "All " + notes.count : "Open"
                onActivated: IslandState.view = "notifications"
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 32
                label: "Clear"
                onActivated: notes.clear()
            }
        }
    }

    Card {
        visible: IslandState.inPanel("apps")
        title: "Launch"

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            uniformCellWidths: true
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
}
