import QtQuick
import QtQuick.Layouts

// One line of a tray menu: an optional icon, the label, and an arrow for submenus.
Rectangle {
    id: root

    property string label: ""
    property url iconSource: ""
    property bool submenu: false
    signal activated()

    implicitHeight: 30
    radius: 9
    color: mouse.containsMouse && root.enabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) : "transparent"
    opacity: root.enabled ? 1 : 0.45

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Image {
            visible: root.iconSource.toString() !== ""
            source: root.iconSource
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            sourceSize.width: 16
            sourceSize.height: 16
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.label
            color: Theme.fg
            font.pixelSize: 13
        }

        Text {
            visible: root.submenu
            text: "›"
            color: Theme.muted
            font.pixelSize: 14
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.activated()
    }
}
