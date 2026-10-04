import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// The wallpaper picker: a grid of thumbnails from the folder, with the current
// one outlined. A click sets that wallpaper, which re-themes everything, and closes
// the island so the change is seen straight away. The folder listing runs only while
// this page is open.
ColumnLayout {
    id: root

    spacing: 10

    readonly property string home: Quickshell.env("HOME")
    readonly property string script: home + "/.local/bin/a4a-wallpaper"

    // {thumb, path} for each image in the folder.
    property var items: []
    // The wallpaper that is set now, from the state file a4a-wallpaper keeps.
    property string current: ""

    DetailHeader {
        title: "Wallpaper"
        backTo: "home"
    }

    Process {
        id: lister
        command: [root.script, "list"]
        running: true

        stdout: StdioCollector {
            id: listed
            onStreamFinished: {
                root.items = listed.text.split("\n").filter(l => l.length > 0).map(l => {
                    const parts = l.split("\t")
                    return { thumb: parts[0], path: parts[1] }
                })
            }
        }
    }

    FileView {
        id: stateFile
        path: root.home + "/.local/state/a4a/wallpaper"
        printErrors: false
        watchChanges: true
        onLoaded: root.current = stateFile.text().trim()
        onFileChanged: stateFile.reload()
    }

    Card {
        title: "Choose one"

        Text {
            Layout.fillWidth: true
            visible: root.items.length === 0
            wrapMode: Text.WordWrap
            text: "No images yet. Put some in ~/Pictures/Wallpapers."
            color: Theme.muted
            font.pixelSize: 12
        }

        GridLayout {
            Layout.fillWidth: true
            visible: root.items.length > 0
            columns: 3
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: root.items

                Rectangle {
                    required property var modelData

                    readonly property bool isCurrent: modelData.path === root.current

                    Layout.fillWidth: true
                    implicitHeight: width * 9 / 16
                    radius: 8
                    color: Theme.surface
                    clip: true
                    border.width: isCurrent ? 2 : 0
                    border.color: Theme.accent

                    Image {
                        anchors.fill: parent
                        anchors.margins: parent.border.width
                        source: "file://" + modelData.thumb
                        // The thumbnail is already small; decode no more than it needs.
                        sourceSize.width: 320
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            IslandState.close()
                            Quickshell.execDetached([root.script, "set", modelData.path])
                        }
                    }
                }
            }
        }
    }
}
