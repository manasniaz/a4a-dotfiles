import QtQuick
import QtQuick.Layouts
import Quickshell

// The pending pacman updates, on the island's home page. Update opens a terminal
// with the upgrade, and the terminal waits for a key before it closes.
Card {
    title: "Updates"

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            Layout.fillWidth: true
            text: Updates.checking && Updates.count === 0 ? "Checking…"
                : Updates.failed ? "Couldn't check for updates"
                : (Updates.count === 0 ? "System is up to date"
                    : Updates.count + (Updates.count === 1 ? " update pending" : " updates pending"))
            color: Theme.fg
            font.pixelSize: 13
        }

        Tile {
            implicitHeight: 32
            label: "Check"
            onActivated: Updates.refresh()
        }

        Tile {
            visible: Updates.count > 0
            implicitHeight: 32
            label: "Update"
            onActivated: IslandState.run([
                "kitty", "--single-instance", "--title", "a4a-update", "-e", "sh", "-c",
                "sudo pacman -Syu; echo; read -r -p 'Done. Press Enter to close.' _"
            ])
        }
    }
}
