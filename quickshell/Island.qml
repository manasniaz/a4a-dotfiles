import QtQuick

// The centre pill. Closed: the Arch mark and the centre items from Settings (time
// first, so the most looked-at thing is in the middle of the screen). Open: the
// island's pages (home, clock, calendar, media, notifications, wallpaper, capture).
Morph {
    id: root

    origin: "centre"
    expandedWidth: 440
    closedWidth: Math.max(120, closedRow.implicitWidth + 2 * 5 + 6)

    Row {
        id: closedRow
        anchors.centerIn: parent
        height: root.pillHeight
        spacing: 2

        ArchMark {
            anchors.verticalCenter: parent.verticalCenter
        }

        Repeater {
            model: IslandState.shownIn("centre")
            delegate: BarItem {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
