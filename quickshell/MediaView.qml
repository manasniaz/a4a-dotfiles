import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

// The screen behind the track in the closed pill: what's playing, its controls,
// and every player that's open.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var player: IslandState.player

    DetailHeader {
        title: "Media"
    }

    Card {
        title: root.player ? root.player.identity : "Nothing playing"

        Text {
            Layout.fillWidth: true
            visible: root.player !== null
            wrapMode: Text.WordWrap
            text: root.player ? IslandState.trackTitle(root.player) : ""
            color: Theme.fg
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            visible: root.player !== null && root.player.trackAlbum !== ""
            elide: Text.ElideRight
            text: root.player ? root.player.trackAlbum : ""
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        Text {
            Layout.fillWidth: true
            visible: root.player === null
            text: "Start something in a player, and it shows up here."
            wrapMode: Text.WordWrap
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            visible: root.player !== null
            spacing: 8

            Item { Layout.fillWidth: true }

            Tile { icon: "prev"; implicitWidth: 52; implicitHeight: 36; onActivated: root.player.previous() }
            Tile { icon: root.player && root.player.isPlaying ? "pause" : "play"; implicitWidth: 52; implicitHeight: 36; onActivated: root.player.togglePlaying() }
            Tile { icon: "next"; implicitWidth: 52; implicitHeight: 36; onActivated: root.player.next() }

            Item { Layout.fillWidth: true }
        }
    }

    Card {
        visible: Mpris.players.values.length > 1
        title: "Players"

        Repeater {
            model: Mpris.players.values

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 34
                radius: 9
                color: modelData === root.player ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.modelData.identity + (parent.modelData.isPlaying ? "  ·  playing" : "")
                    color: Theme.fg
                    font.pixelSize: 13
                }
            }
        }
    }
}
