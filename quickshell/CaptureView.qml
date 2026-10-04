import QtQuick
import QtQuick.Layouts
import Quickshell

// The capture menu, behind the camera icon in the island header. Both actions
// close the island first, so the capture doesn't include it.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "Capture"
        backTo: "home"
    }

    Card {
        title: "Screenshot"

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Region"
                onActivated: IslandState.run([Quickshell.env("HOME") + "/.local/bin/a4a-screenshot", "region"])
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Whole screen"
                onActivated: IslandState.run([Quickshell.env("HOME") + "/.local/bin/a4a-screenshot", "full"])
            }
        }
    }
}
