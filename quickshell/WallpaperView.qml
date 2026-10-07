import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// The wallpaper picker (SUPER+W, or the island's image button). A grid of the
// folder's images, browsable with the keyboard:
//   arrows, Home, End   move; after a short pause the desktop shows the selection
//   Enter               keep it: re-theme everything from it, and close
//   Escape, a click away   close and put the old wallpaper back
// A click on a thumbnail keeps that one straight away.
//
// The preview only swaps the desktop image (a4a-wallpaper preview, from a cached
// screen-sized copy, so it keeps up with held keys). Nothing is re-themed or
// remembered until Enter, so browsing is free to undo.
ColumnLayout {
    id: root

    spacing: 10

    readonly property string script: Quickshell.env("HOME") + "/.local/bin/a4a-wallpaper"
    readonly property int columns: 3

    // {thumb, path} for each image in the folder.
    property var items: []
    // The wallpaper when the picker opened: what Escape goes back to.
    property string original: ""
    property int selected: -1
    // What the desktop shows now, if a preview has replaced the original.
    property string previewing: ""
    property bool applied: false

    readonly property var current: selected >= 0 && selected < items.length ? items[selected] : null

    // "nihilist-penguin-5120x2880-25229.jpg" -> "Nihilist penguin"
    function prettyName(path) {
        const file = path.split("/").pop().replace(/\.[^.]+$/, "")
        const words = file.replace(/[-_]+/g, " ").replace(/\s*\d+x\d+.*$/, "").replace(/\s+\d+$/, "").trim()
        return words.length > 0 ? words[0].toUpperCase() + words.slice(1) : file
    }

    function select(i) {
        if (items.length === 0)
            return
        selected = Math.max(0, Math.min(items.length - 1, i))
        previewTimer.restart()
    }

    function apply(path) {
        applied = true
        IslandState.close()
        Quickshell.execDetached([script, "set", path])
    }

    function handleKey(event) {
        if (items.length === 0)
            return false
        const at = selected < 0 ? 0 : selected
        switch (event.key) {
        case Qt.Key_Right: select(at + 1); return true
        case Qt.Key_Left: select(at - 1); return true
        case Qt.Key_Down: select(at + columns); return true
        case Qt.Key_Up: select(at - columns); return true
        case Qt.Key_Home: select(0); return true
        case Qt.Key_End: select(items.length - 1); return true
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            if (current)
                apply(current.path)
            return true
        }
        return false
    }

    // Wait for the keys to settle before swapping the desktop, so holding an arrow
    // doesn't queue a preview for every image it passes.
    Timer {
        id: previewTimer
        interval: 160
        onTriggered: {
            if (!root.current || root.current.path === root.previewing)
                return
            // Back on the original: show the real file, not a copy.
            if (root.current.path === root.original && root.previewing === "")
                return
            root.previewing = root.current.path
            Quickshell.execDetached([root.script, "preview", root.current.path])
        }
    }

    // Leaving without Enter (Escape, a click outside, another page) undoes the preview.
    Component.onDestruction: {
        if (!applied && previewing !== "" && original !== "")
            Quickshell.execDetached(["awww", "img", "--transition-type", "fade", "--transition-duration", "0.25", original])
    }

    DetailHeader {
        title: "Wallpaper"
    }

    Process {
        command: [root.script, "current"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.original = text.trim()
                const i = root.items.findIndex(it => it.path === root.original)
                if (i >= 0 && root.selected < 0)
                    root.selected = i
            }
        }
    }

    Process {
        command: [root.script, "list"]
        running: true

        stdout: StdioCollector {
            id: listed
            onStreamFinished: {
                root.items = listed.text.split("\n").filter(l => l.length > 0).map(l => {
                    const parts = l.split("\t")
                    return { thumb: parts[0], path: parts[1] }
                })
                const i = root.items.findIndex(it => it.path === root.original)
                if (root.selected < 0)
                    root.selected = Math.max(0, i)
                // Screen-sized copies for the previews, made at low priority.
                Quickshell.execDetached([root.script, "warm"])
            }
        }
    }

    Card {
        title: root.current ? root.prettyName(root.current.path) : "Choose one"

        Text {
            Layout.fillWidth: true
            visible: root.items.length === 0
            wrapMode: Text.WordWrap
            text: "No images yet. Put some in ~/Pictures/Wallpapers."
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        GridLayout {
            Layout.fillWidth: true
            visible: root.items.length > 0
            columns: root.columns
            uniformCellWidths: true
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: root.items

                Item {
                    id: cell
                    required property var modelData
                    required property int index

                    readonly property bool isOriginal: modelData.path === root.original
                    readonly property bool isSelected: index === root.selected

                    Layout.fillWidth: true
                    implicitHeight: width * 10 / 16

                    // The selection ring sits outside the image, so the picture itself
                    // is never covered.
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: 11
                        color: "transparent"
                        border.width: 2
                        border.color: Theme.accent
                        opacity: cell.isSelected ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.surface
                        clip: true
                        scale: cell.isSelected ? 1 : (mouse.containsMouse ? 0.98 : 0.96)

                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                        Image {
                            anchors.fill: parent
                            source: "file://" + cell.modelData.thumb
                            // The thumbnail is already small; decode no more than it needs.
                            sourceSize.width: 320
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            opacity: cell.isSelected || mouse.containsMouse ? 1 : 0.72

                            Behavior on opacity { NumberAnimation { duration: 140 } }
                        }

                        // The wallpaper in use now: a small dot in the corner.
                        Rectangle {
                            visible: cell.isOriginal
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 6
                            width: 8
                            height: 8
                            radius: 4
                            color: Theme.accent
                            border.width: 1
                            border.color: Theme.bg
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.apply(cell.modelData.path)
                    }
                }
            }
        }

        Text {
            visible: root.items.length > 0
            Layout.fillWidth: true
            Layout.topMargin: 2
            text: "Arrows to look around · Enter to keep · Esc to go back"
            color: Theme.fgFaint
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
