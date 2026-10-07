import QtQuick
import QtQuick.Layouts

// The header for every screen under the home view: a back arrow, a title, an
// optional control on the right, and the close button.
RowLayout {
    id: root

    property string title
    // Where the back arrow goes. Empty: the home of the panel that's showing.
    property string backTo: ""
    default property alias extra: slot.data

    Layout.fillWidth: true
    spacing: 8

    Tile {
        icon: "back"
        implicitWidth: 36
        implicitHeight: 32
        onActivated: root.backTo !== "" ? IslandState.view = root.backTo : IslandState.back()
    }

    Text {
        Layout.fillWidth: true
        text: root.title
        color: Theme.fg
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    RowLayout {
        id: slot
        spacing: 8
    }

    Tile {
        icon: "close"
        implicitWidth: 36
        implicitHeight: 32
        onActivated: IslandState.close()
    }
}
