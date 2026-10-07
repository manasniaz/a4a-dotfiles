import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

// Bluetooth: the adapter switch, your devices, then devices nearby. A click on one
// of yours connects or disconnects it; a click on a nearby one pairs it. If the
// device needs a code confirmed, the pairing card takes over this panel (the agent,
// scripts/a4a-bt-agent, asks), then comes back here. Paired devices are trusted by
// the agent, so they reconnect by themselves. Scanning runs only while this page is
// open. The panel scrolls this, so the lists are plain columns.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter !== null && adapter.enabled
    readonly property var devices: on ? adapter.devices.values : []
    readonly property var mine: devices.filter(d => d.paired)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    // Beacons and nameless things only show their address; they aren't pairable in
    // any useful way, so they're left out.
    readonly property var nearby: devices.filter(d => !d.paired && d.deviceName !== "" && d.name !== d.address.replace(/:/g, "-"))

    // Look for nearby devices while this page is on screen.
    Binding {
        target: root.adapter
        property: "discovering"
        value: true
        when: IslandState.view === "bluetooth" && root.on
    }

    // A device's kind, from the icon name BlueZ gives it.
    function glyph(d) {
        const i = d.icon || ""
        if (i.includes("mouse")) return "dev-mouse"
        if (i.includes("keyboard")) return "dev-keyboard"
        if (i.includes("headset") || i.includes("headphone")) return "dev-headphones"
        if (i.includes("phone")) return "dev-phone"
        if (i.includes("gaming") || i.includes("joystick")) return "dev-gamepad"
        if (i.includes("computer")) return "dev-computer"
        if (i.includes("audio") || i.includes("speaker")) return "dev-speaker"
        return "bluetooth"
    }

    DetailHeader {
        title: "Bluetooth"

        Switch {
            checked: root.on
            visible: root.adapter !== null
            onToggled: root.adapter.enabled = !root.adapter.enabled
        }
    }

    Text {
        Layout.fillWidth: true
        visible: !root.on
        text: !root.adapter ? "No Bluetooth adapter found" : "Bluetooth is off"
        color: Theme.fgFaint
        font.pixelSize: 11
    }

    // One device row; used in both lists.
    component DeviceRow: Rectangle {
        id: row
        required property var modelData
        readonly property var dev: modelData
        readonly property bool busy: dev.pairing || dev.state === BluetoothDeviceState.Connecting
            || dev.state === BluetoothDeviceState.Disconnecting

        Layout.fillWidth: true
        implicitHeight: 44
        radius: 10
        color: hover.hovered ? Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.06) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        HoverHandler {
            id: hover
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (row.dev.connected)
                    row.dev.disconnect()
                else if (row.dev.paired)
                    row.dev.connect()
                else if (row.dev.pairing)
                    row.dev.cancelPair()
                else
                    row.dev.pair()
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 10

            Icon {
                kind: root.glyph(row.dev)
                color: row.dev.connected ? Theme.accent : Theme.fg
                font.pixelSize: 18
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: row.dev.name
                    color: row.dev.connected ? Theme.accent : Theme.fg
                    font.pixelSize: 13
                    font.weight: row.dev.connected ? Font.DemiBold : Font.Normal
                }

                Text {
                    text: row.dev.pairing ? "Pairing… (click to stop)"
                        : row.dev.state === BluetoothDeviceState.Connecting ? "Connecting…"
                        : row.dev.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                        : row.dev.connected ? "Connected"
                        : row.dev.paired ? "Not connected" : "Click to pair"
                    color: Theme.fgFaint
                    font.pixelSize: 10
                }
            }

            Tile {
                visible: row.dev.paired && hover.hovered && !row.busy
                implicitHeight: 26
                label: "Forget"
                onActivated: row.dev.forget()
            }

            Text {
                visible: row.dev.batteryAvailable
                text: Math.round(row.dev.battery * 100) + "%"
                color: Theme.fgFaint
                font.pixelSize: 11
                font.features: { "tnum": 1 }
            }
        }
    }

    Card {
        visible: root.on
        title: "My devices"

        Text {
            visible: root.mine.length === 0
            text: "None paired yet."
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        Repeater {
            model: root.mine
            delegate: DeviceRow {}
        }
    }

    Card {
        visible: root.on
        title: root.nearby.length > 0 ? "Nearby" : "Nearby · looking…"

        Text {
            visible: root.nearby.length === 0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Put the device in pairing mode (hold its Bluetooth or connect button until it blinks)."
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        Repeater {
            model: root.nearby
            delegate: DeviceRow {}
        }
    }

    // Phones and other computers only find this one while it's visible.
    OptionRow {
        visible: root.on
        label: "Visible to other devices"
        hint: "For pairing from a phone. Turns itself off after 3 minutes."
        checked: root.adapter !== null && root.adapter.discoverable
        onToggled: root.adapter.discoverable = !root.adapter.discoverable
    }
}
