import QtQuick
import QtQuick.Layouts
import Quickshell

// The notification centre: every notification in dunst's history, newest first,
// with a clear-all. SUPER+N, or "All" on the island's home page.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "Notifications"
    }

    Card {
        title: list.count > 0 ? "Recent · " + list.count : "Recent"

        NotificationList {
            id: list
        }

        Tile {
            visible: list.count > 0
            Layout.fillWidth: true
            implicitHeight: 34
            label: "Clear all"
            onActivated: list.clear()
        }
    }
}
