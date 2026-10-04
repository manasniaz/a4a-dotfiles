import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

// Bluetooth detail: the adapter switch, then the devices it knows. Click a device
// to connect or disconnect it. Scanning runs only while this view is open. The
// island's panel scrolls this, so the list is a plain column.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter && adapter.enabled ? adapter.devices.values : []

    // Look for nearby devices while this view is on screen.
    Binding {
        target: root.adapter
        property: "discovering"
        value: true
        when: IslandState.view === "bluetooth" && root.adapter !== null && root.adapter.enabled
    }

    DetailHeader {
        title: "Bluetooth"
        backTo: "home"

        Switch {
            checked: root.adapter !== null && root.adapter.enabled
            visible: root.adapter !== null
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }
    }

    Text {
        Layout.fillWidth: true
        text: !root.adapter ? "No Bluetooth adapter found"
            : (!root.adapter.enabled ? "Bluetooth is off" : "Devices")
        color: Theme.muted
        font.pixelSize: 11
    }

    Repeater {
        model: root.devices

        Rectangle {
            id: entry
            required property var modelData

            Layout.fillWidth: true
            implicitHeight: 40
            radius: 10
            color: devMouse.containsMouse ? Qt.lighter(Theme.card, 1.15) : "transparent"

            MouseArea {
                id: devMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: entry.modelData.connected ? entry.modelData.disconnect() : entry.modelData.connect()
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: entry.modelData.name
                    color: entry.modelData.connected ? Theme.accent : Theme.fg
                    font.pixelSize: 13
                }

                Text {
                    text: entry.modelData.connected ? "connected" : (entry.modelData.paired ? "paired" : "nearby")
                    color: Theme.muted
                    font.pixelSize: 10
                }
            }
        }
    }

    Text {
        visible: root.devices.length === 0 && root.adapter !== null && root.adapter.enabled
        text: "No devices yet. Put one in pairing mode."
        color: Theme.muted
        font.pixelSize: 12
    }
}
