import QtQuick
import QtQuick.Layouts

// The Arch Linux mark, always first in the closed pill. It's the one thing that
// opens the whole island. With nothing selected to show, it carries its name too.
Item {
    id: root

    // Only when the island shows nothing else, so the pill stays short.
    readonly property bool showName: IslandState.shownIn("centre").length === 0

    implicitWidth: row.implicitWidth + 2 * 6
    implicitHeight: 28

    Hover {
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7
        scale: mouse.pressed ? 0.94 : 1

        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        Icon {
            Layout.alignment: Qt.AlignVCenter
            kind: "arch"
            color: Theme.arch
            font.pixelSize: 22
        }

        Text {
            visible: root.showName
            Layout.alignment: Qt.AlignVCenter
            text: "Arch Linux"
            color: Theme.fg
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
    }

    // Over the whole mark, so the logo and its name both open the island.
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandState.toggle()
    }
}
