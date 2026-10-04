import QtQuick
import QtQuick.Layouts

// Wi-Fi or Bluetooth on the home view. The card opens the detail list, and the
// switch on the right turns the radio on or off without opening anything.
Rectangle {
    id: root

    property string title
    property string status
    property bool on: false
    signal opened()
    signal toggled()

    Layout.fillWidth: true
    implicitHeight: 62
    radius: 14
    color: Theme.card

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.opened()
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: switchItem.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 10
        spacing: 2

        Text {
            text: root.title
            color: Theme.fg
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: root.status
            elide: Text.ElideRight
            color: root.on ? Theme.accent : Theme.muted
            font.pixelSize: 11
        }
    }

    Switch {
        id: switchItem
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        checked: root.on
        onToggled: root.toggled()
    }
}
