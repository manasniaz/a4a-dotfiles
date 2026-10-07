import QtQuick
import QtQuick.Layouts

// A group inside the island: a rounded card with a small caps title. Everything
// placed inside it is stacked with the same spacing, so groups line up.
Rectangle {
    id: root

    property string title: ""
    default property alias content: body.data

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + 24
    radius: 14
    color: Theme.card

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        Text {
            visible: root.title !== ""
            text: root.title
            color: Theme.fgFaint
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.letterSpacing: 1
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 8
        }
    }
}
