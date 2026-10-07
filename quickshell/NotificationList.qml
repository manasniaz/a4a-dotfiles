import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Recent notifications from dunst's history, newest first. Read once when the page
// that holds this opens, so nothing polls. dunst adds a notification to its history
// when its popup closes, so one still on screen isn't listed yet.
ColumnLayout {
    id: root

    // How many to show; -1 for all of them.
    property int limit: -1
    // {app, summary, body} for each entry, newest first.
    property var items: []
    readonly property int count: items.length

    function clear() {
        Quickshell.execDetached(["dunstctl", "history-clear"])
        items = []
    }

    Layout.fillWidth: true
    spacing: 10

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

    Text {
        Layout.fillWidth: true
        visible: root.items.length === 0
        text: "Nothing new."
        color: Theme.fgFaint
        font.pixelSize: 12
    }

    Repeater {
        model: root.limit < 0 ? root.items : root.items.slice(0, root.limit)

        ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: modelData.app
                color: Theme.fgFaint
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
                color: Theme.fgDim
                font.pixelSize: 12
            }
        }
    }
}
