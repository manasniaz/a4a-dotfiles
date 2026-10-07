import QtQuick

// A pill that grows into its panel: the island in the centre, and the right pill
// into the control centre. Closed, it shows its row; open, the page of its panel.
// One progress value (0 closed, 1 open) drives the size, the corners and the fades,
// so the whole thing moves as one motion. Both pills use this, so they open, close
// and resize the same way.
Item {
    id: root

    // "centre" or "status".
    required property string origin
    property real pillHeight: 38
    property real expandedWidth: 440
    // Width of the closed row, from the caller; eases when it changes (a track
    // starting widens the island smoothly).
    property real closedWidth: 120
    // The closed row goes here.
    default property alias closedContent: closedSlot.data
    readonly property alias body: panel

    readonly property bool isOpen: IslandState.open && IslandState.origin === origin

    // Animated: 0 is closed, 1 is open. Opening and closing run the same curve.
    property real progress: isOpen ? 1 : 0
    Behavior on progress {
        NumberAnimation { duration: 340; easing.type: Easing.OutCubic }
    }

    property real collapsedWidth: closedWidth
    Behavior on collapsedWidth {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    // Follows the page's height, and eases when the page changes size. Not while
    // opening: the progress curve already grows it, and two easings fight.
    property real expandedHeight: panel.implicitHeight + 28
    Behavior on expandedHeight {
        enabled: root.progress === 1
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    implicitWidth: collapsedWidth + (expandedWidth - collapsedWidth) * progress
    implicitHeight: pillHeight + (expandedHeight - pillHeight) * progress
    width: implicitWidth
    height: implicitHeight

    BarPill {
        anchors.fill: parent
        radius: root.pillHeight / 2 + (22 - root.pillHeight / 2) * root.progress
        surface.clip: true

        // Closed content: fades out as the pill opens, and in again as it closes.
        Item {
            id: closedSlot
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.pillHeight
            opacity: Math.max(0, 1 - root.progress * 3)
            visible: opacity > 0
        }

        // Open content: fades in after the pill has mostly grown, and scales up from
        // slightly smaller, so it feels like it unfolds from the pill.
        PanelBody {
            id: panel
            origin: root.origin
            live: root.isOpen || root.progress > 0
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
