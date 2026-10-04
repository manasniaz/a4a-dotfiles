import QtQuick
import QtQuick.Layouts

// A labelled bar: "CPU ▮▮▯▯ 42%". Used for CPU, RAM and battery so they all read
// the same way at a glance.
RowLayout {
    id: root

    property string label
    // 0 to 1
    property real value: 0
    property string valueText: ""
    property color fillColor: Theme.accent

    spacing: 7

    Text {
        text: root.label
        color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.6)
        font.pixelSize: 11
        font.letterSpacing: 0.6
    }

    Rectangle {
        implicitWidth: 42
        implicitHeight: 6
        radius: 3
        color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.6)

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0, Math.min(1, root.value))
            radius: 3
            color: root.fillColor

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        text: root.valueText
        color: Theme.fg
        font.pixelSize: 12
        Layout.minimumWidth: 34
    }
}
