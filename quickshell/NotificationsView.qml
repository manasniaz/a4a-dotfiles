import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// The notification centre: the recent notifications from dunst's history, newest
// first, with a clear-all. The history is read when the page opens, so nothing
// polls in the background.
ColumnLayout {
    id: root

    spacing: 10

    // {app, summary, body} for each entry, newest first.
    property var items: []

    DetailHeader {
        title: "Notifications"
        backTo: "home"
    }

    Process {
        command: ["dunstctl", "history"]
        running: true

        stdout: StdioCollector {
            id: history
            onStreamFinished: {
                let entries = []
                try {
                    // dunstctl prints a variant tree: data[0] is the list of entries,
                    // and each field is {type, data}.
                    const list = JSON.parse(history.text).data[0] || []
                    entries = list.map(e => ({
                        app: e.appname?.data ?? "",
                        summary: e.summary?.data ?? "",
                        body: e.body?.data ?? ""
                    })).reverse()
                } catch (err) {
                    // dunst not running, or nothing in its history: an empty list.
                }
                root.items = entries
            }
        }
    }

    Card {
        title: root.items.length > 0 ? "Recent · " + root.items.length : "Recent"

        Text {
            Layout.fillWidth: true
            visible: root.items.length === 0
            text: "Nothing yet. A notification lands here once its popup has gone."
            wrapMode: Text.WordWrap
            color: Theme.muted
            font.pixelSize: 12
        }

        Repeater {
            model: root.items

            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: modelData.app
                    color: Theme.muted
                    font.pixelSize: 10
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                }

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: modelData.summary
                    color: Theme.fg
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    visible: modelData.body !== ""
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    text: modelData.body
                    color: Theme.fg
                    font.pixelSize: 12
                }
            }
        }

        Tile {
            visible: root.items.length > 0
            Layout.fillWidth: true
            implicitHeight: 34
            label: "Clear all"
            onActivated: {
                Quickshell.execDetached(["dunstctl", "history-clear"])
                root.items = []
            }
        }
    }
}
