import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

// Wi-Fi detail: the radio switch, then the networks nearby. Open and saved
// networks connect with one click. A secured network you haven't joined before
// opens a password field under it. The island's own panel scrolls this, so the
// list is a plain column and never scrolls by itself.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var current: wifi ? wifi.networks.values.find(n => n.connected) ?? null : null
    readonly property var networks: wifi ? wifi.networks.values : []
    property string picking: ""

    // Scan only while this view is on screen. The scanner belongs to the Wi-Fi device.
    Binding {
        target: root.wifi
        property: "scannerEnabled"
        value: IslandState.view === "wifi"
        when: root.wifi !== null
    }

    DetailHeader {
        title: "Wi-Fi"
        backTo: "home"

        Switch {
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Text {
        Layout.fillWidth: true
        text: !Networking.wifiEnabled ? "Wi-Fi is off"
            : (root.current ? "Connected to " + root.current.name : "Not connected")
        color: Theme.muted
        font.pixelSize: 11
    }

    Repeater {
        model: Networking.wifiEnabled ? root.networks : []

        ColumnLayout {
            id: entry
            required property var modelData

            Layout.fillWidth: true
            spacing: 4

            readonly property bool secured: modelData.security !== WifiSecurityType.Open
            readonly property bool needsPassword: secured && !modelData.known && !modelData.connected

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 10
                color: rowMouse.containsMouse ? Qt.lighter(Theme.card, 1.15) : "transparent"

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (entry.modelData.connected)
                            entry.modelData.disconnect()
                        else if (!entry.needsPassword)
                            entry.modelData.connect()
                        else
                            root.picking = root.picking === entry.modelData.name ? "" : entry.modelData.name
                    }
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
                        text: entry.secured ? "secured" : "open"
                        color: Theme.muted
                        font.pixelSize: 10
                    }

                    Text {
                        text: Math.round(entry.modelData.signalStrength * 100) + "%"
                        color: Theme.muted
                        font.pixelSize: 11
                    }
                }
            }

            // Password field, shown under a secured network you haven't joined.
            Rectangle {
                visible: entry.needsPassword && root.picking === entry.modelData.name
                Layout.fillWidth: true
                implicitHeight: visible ? 40 : 0
                radius: 10
                color: Theme.bg

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 6

                    TextInput {
                        id: pass
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        color: Theme.fg
                        font.pixelSize: 13
                        clip: true
                        focus: parent.visible
                        verticalAlignment: TextInput.AlignVCenter
                        onAccepted: join.trigger()
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: pass.text === ""
                            text: "Password"
                            color: Theme.muted
                            font.pixelSize: 13
                        }
                    }

                    Tile {
                        id: join
                        label: "Join"
                        implicitHeight: 28
                        function trigger() {
                            if (pass.text !== "") {
                                entry.modelData.connectWithPsk(pass.text)
                                pass.text = ""
                                root.picking = ""
                            }
                        }
                        onActivated: trigger()
                    }
                }
            }
        }
    }

    Text {
        visible: Networking.wifiEnabled && root.networks.length === 0
        text: "Looking for networks…"
        color: Theme.muted
        font.pixelSize: 12
    }
}
