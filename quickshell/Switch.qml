import QtQuick

// On/off toggle. The knob slides and the track changes colour.
Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 38
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accent : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.9)

    Behavior on color {
        ColorAnimation { duration: 160 }
    }

    Rectangle {
        id: knob
        width: 16
        height: 16
        radius: 8
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.bg : Theme.fg

        Behavior on x {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
