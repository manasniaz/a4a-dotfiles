import QtQuick
import QtQuick.Layouts

// The header for every screen under the home view: a back arrow, a title, an
// optional control on the right, and the close button.
RowLayout {
    id: root

    property string title
    property string backTo: "home"
    default property alias extra: slot.data

    Layout.fillWidth: true
    spacing: 8

    Tile {
        label: "←"
        implicitWidth: 36
        implicitHeight: 32
        onActivated: IslandState.view = root.backTo
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
        label: "✕"
        implicitWidth: 36
        implicitHeight: 32
        onActivated: IslandState.close()
    }
}
