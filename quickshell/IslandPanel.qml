import QtQuick
import QtQuick.Layouts
import Quickshell

// The island expanded. The header shows the clock on the home view, and a title
// with a back arrow everywhere else. The body is whichever view is current.
ColumnLayout {
    id: root

    spacing: 10

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property bool home: IslandState.view === "home"

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: root.home

        ColumnLayout {
            spacing: 0

            Text {
                text: Qt.formatTime(clock.date, "HH:mm")
                color: Theme.fg
                font.pixelSize: 26
                font.weight: Font.DemiBold
            }

            Text {
                text: Qt.formatDate(clock.date, "dddd, d MMMM")
                color: Theme.muted
                font.pixelSize: 11
            }
        }

        Item { Layout.fillWidth: true }

        Tile {
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.view = "notifications"

            Icon {
                anchors.centerIn: parent
                kind: "bell"
                font.pixelSize: 16
                color: Theme.fg
            }
        }

        Tile {
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.view = "wallpaper"

            Icon {
                anchors.centerIn: parent
                kind: "image"
                font.pixelSize: 16
                color: Theme.fg
            }
        }

        Tile {
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.view = "capture"

            Icon {
                anchors.centerIn: parent
                kind: "camera"
                font.pixelSize: 16
                color: Theme.fg
            }
        }

        Tile {
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.view = "power"

            Icon {
                anchors.centerIn: parent
                kind: "power"
                font.pixelSize: 16
                color: Theme.fg
            }
        }

        Tile {
            label: "⚙"
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.view = "settings"
        }

        Tile {
            label: "✕"
            implicitWidth: 36
            implicitHeight: 36
            onActivated: IslandState.close()
        }
    }

    // The current screen scrolls when it's taller than the panel allows.
    Flickable {
        id: scroller
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(body.height, root.maxBodyHeight)
        contentHeight: body.height
        contentWidth: width
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Loader {
            id: body
            width: scroller.width
            height: item ? item.implicitHeight : 0
            sourceComponent: IslandState.view === "wifi" ? wifiView
                : IslandState.view === "bluetooth" ? bluetoothView
                : IslandState.view === "calendar" ? calendarView
                : IslandState.view === "clock" ? clockView
                : IslandState.view === "media" ? mediaView
                : IslandState.view === "network" ? networkView
                : IslandState.view === "sound" ? soundView
                : IslandState.view === "system" ? systemView
                : IslandState.view === "settings" ? settingsView
                : IslandState.view === "wallpaper" ? wallpaperView
                : IslandState.view === "power" ? powerView
                : IslandState.view === "capture" ? captureView
                : IslandState.view === "notifications" ? notificationsView
                : homeView
        }
    }

    // Tallest the scrolling area gets, so the island stays a sensible size.
    readonly property int maxBodyHeight: 1000

    Component { id: homeView; HomeView {} }
    Component { id: wifiView; WifiView {} }
    Component { id: bluetoothView; BluetoothView {} }
    Component { id: settingsView; SettingsView {} }
    Component { id: calendarView; CalendarView {} }
    Component { id: systemView; SystemView {} }
    Component { id: clockView; ClockView {} }
    Component { id: mediaView; MediaView {} }
    Component { id: networkView; NetworkView {} }
    Component { id: soundView; SoundView {} }
    Component { id: wallpaperView; WallpaperView {} }
    Component { id: powerView; PowerView {} }
    Component { id: captureView; CaptureView {} }
    Component { id: notificationsView; NotificationsView {} }
}
