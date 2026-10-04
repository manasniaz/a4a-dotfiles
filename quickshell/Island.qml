import QtQuick
import Quickshell

// The centre pill. Closed, it shows the choices from Settings. Open, it grows
// into the control panel. One progress value (0 closed, 1 open) drives the size,
// the corner radius and the fades, so the whole thing moves as one motion.
Item {
    id: root

    // The bar sets this to the height of the pill row.
    property real pillHeight: 38

    // Animated: 0 is closed, 1 is open. Opening and closing run the same curve.
    property real progress: IslandState.open ? 1 : 0
    Behavior on progress {
        NumberAnimation { duration: 340; easing.type: Easing.OutCubic }
    }

    readonly property real collapsedWidth: Math.max(150, closedRow.implicitWidth + 28)
    readonly property real expandedWidth: 440
    // Follows the panel's height, and eases when the view changes size.
    property real expandedHeight: panel.implicitHeight + 28
    Behavior on expandedHeight {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    implicitWidth: collapsedWidth + (expandedWidth - collapsedWidth) * progress
    implicitHeight: pillHeight + (expandedHeight - pillHeight) * progress
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: root.pillHeight / 2 + (22 - root.pillHeight / 2) * root.progress
        color: Theme.pill
        border.width: 1
        border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)
        clip: true

        // Closed content: fades out as the pill opens, and in again as it closes.
        Row {
            id: closedRow
            anchors.centerIn: parent
            height: root.pillHeight
            opacity: Math.max(0, 1 - root.progress * 3)
            spacing: 0

            ArchMark {
                anchors.verticalCenter: parent.verticalCenter
            }

            Repeater {
                model: IslandState.shown
                delegate: ClosedItem {}
            }
        }

        // Open content: fades in after the pill has mostly grown, and scales up from
        // slightly smaller, so it feels like it unfolds from the pill.
        IslandPanel {
            id: panel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            opacity: Math.max(0, (root.progress - 0.35) / 0.65)
            scale: 0.97 + 0.03 * root.progress
            transformOrigin: Item.Top
            visible: opacity > 0
        }
    }
}
