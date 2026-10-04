import QtQuick

// A horizontal slider for a 0 to 1 value. Drag or click anywhere on the track.
Item {
    id: root

    property real value: 0
    signal moved(real value)

    implicitHeight: 20
    implicitWidth: 160

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.6)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: 3
            color: Theme.accent
        }
    }

    Rectangle {
        width: 14
        height: 14
        radius: 7
        color: Theme.fg
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, root.value)) * (root.width - width)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function setFrom(mx) {
            const v = Math.max(0, Math.min(1, mx / root.width))
            root.moved(v)
        }
        onPressed: setFrom(mouse.x)
        onPositionChanged: if (pressed) setFrom(mouse.x)
    }
}
