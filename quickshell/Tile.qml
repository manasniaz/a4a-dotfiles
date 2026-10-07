import QtQuick

// One button in the island panel. Hover lifts it slightly, so it reads as clickable.
Rectangle {
    id: root

    property string label
    // A glyph name from Icon.qml, shown instead of the label.
    property string icon: ""
    // Power actions use this to show they are armed for a second click.
    property bool armed: false
    signal activated()

    implicitHeight: 38
    // Size to the label, with room either side, unless the caller sets a width.
    implicitWidth: Math.max(56, labelText.implicitWidth + 28)
    radius: 12
    color: armed
        ? Theme.accent
        : (mouse.containsMouse
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)
            : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.25))

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        visible: root.icon === ""
        text: root.label
        color: root.armed ? Theme.bg : Theme.fg
        font.pixelSize: 13
    }

    Icon {
        anchors.centerIn: parent
        visible: root.icon !== ""
        kind: root.icon
        color: root.armed ? Theme.bg : Theme.fg
        font.pixelSize: 16
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
    }
}
