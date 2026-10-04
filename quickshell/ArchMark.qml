import QtQuick
import QtQuick.Layouts

// The Arch Linux mark, always first in the closed pill. It's the one thing that
// opens the whole island. With nothing selected to show, it carries its name too.
Item {
    id: root

    // Set false while something is shown after it, so the pill stays short.
    readonly property bool showName: IslandState.shown.length === 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

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
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandState.toggle()
    }
}
