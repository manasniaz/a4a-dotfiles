import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

// Wi-Fi: the radio switch, then the networks nearby, strongest first, the joined one
// on top. A click does the obvious thing for each kind of network:
//   joined                 disconnect
//   saved, or open         connect
//   password (WPA-PSK)     a password field under it
//   enterprise (802.1X)    a sign-in form under it (EnterpriseForm: eduroam and the like)
// Saved networks can be forgotten from their row. Connecting and failing show under
// the row, so a wrong password says so instead of nothing happening.
// The panel scrolls this, so the list is a plain column.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var current: wifi ? wifi.networks.values.find(n => n.connected) ?? null : null
    readonly property var networks: {
        const list = wifi ? wifi.networks.values.slice() : []
        return list.sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    }
    // The network whose form is open, by name.
    property string picking: ""
    // Last failure, by network name: {name, text}.
    property var failure: null

    function isEnterprise(n) {
        return n.security === WifiSecurityType.Wpa2Eap || n.security === WifiSecurityType.WpaEap
            || n.security === WifiSecurityType.Wpa3SuiteB192 || n.security === WifiSecurityType.Leap
            || n.security === WifiSecurityType.DynamicWep
    }

    // Scan only while this page is on screen. The scanner belongs to the Wi-Fi device.
    Binding {
        target: root.wifi
        property: "scannerEnabled"
        value: IslandState.view === "wifi"
        when: root.wifi !== null
    }

    DetailHeader {
        title: "Wi-Fi"

        Switch {
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Text {
        Layout.fillWidth: true
        text: !Networking.wifiEnabled ? "Wi-Fi is off"
            : (root.current ? "Connected to " + root.current.name : "Not connected")
        color: Theme.fgFaint
        font.pixelSize: 11
    }

    Repeater {
        model: Networking.wifiEnabled ? root.networks : []

        ColumnLayout {
            id: entry
            required property var modelData

            Layout.fillWidth: true
            spacing: 6

            readonly property var net: modelData
            readonly property bool secured: net.security !== WifiSecurityType.Open
            readonly property bool enterprise: root.isEnterprise(net)
            readonly property bool needsForm: secured && !net.known && !net.connected
            readonly property bool open: root.picking === net.name
            readonly property bool busy: net.state === ConnectionState.Connecting || net.stateChanging
            readonly property string failText: root.failure && root.failure.name === net.name ? root.failure.text : ""

            Connections {
                target: entry.net
                function onConnectionFailed(reason) {
                    root.failure = {
                        name: entry.net.name,
                        text: reason === ConnectionFailReason.NoSecrets ? "Wrong password, or the network refused it."
                            : reason === ConnectionFailReason.WifiAuthTimeout ? "The network didn't answer in time."
                            : reason === ConnectionFailReason.WifiNetworkLost ? "The network went out of range."
                            : "Couldn't connect."
                    }
                }
                function onConnectedChanged() {
                    if (entry.net.connected && root.failure && root.failure.name === entry.net.name)
                        root.failure = null
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: 10
                color: rowHover.hovered || entry.open ? Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.06) : "transparent"

                Behavior on color { ColorAnimation { duration: 120 } }

                // Passive, so it stays hovered over the row's own buttons too.
                HoverHandler {
                    id: rowHover
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.failure = null
                        if (entry.net.connected)
                            entry.net.disconnect()
                        else if (!entry.needsForm)
                            entry.net.connect()
                        else
                            root.picking = entry.open ? "" : entry.net.name
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 10

                    WifiGlyph {
                        value: entry.net.signalStrength
                        color: entry.net.connected ? Theme.accent : Theme.fg
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: entry.net.name
                            color: entry.net.connected ? Theme.accent : Theme.fg
                            font.pixelSize: 13
                            font.weight: entry.net.connected ? Font.DemiBold : Font.Normal
                        }

                        Text {
                            text: entry.busy ? "Connecting…"
                                : entry.net.connected ? "Connected"
                                : [entry.net.known ? "Saved" : "",
                                   entry.enterprise ? "Sign-in (enterprise)" : (entry.secured ? "Password" : "Open")]
                                    .filter(s => s).join(" · ")
                            color: Theme.fgFaint
                            font.pixelSize: 10
                        }
                    }

                    // Saved networks: forget. Only on hover, so the list stays calm.
                    Tile {
                        visible: entry.net.known && rowHover.hovered
                        implicitHeight: 26
                        label: "Forget"
                        onActivated: {
                            if (root.picking === entry.net.name)
                                root.picking = ""
                            entry.net.forget()
                        }
                    }

                    Text {
                        text: Math.round(entry.net.signalStrength * 100) + "%"
                        color: Theme.fgFaint
                        font.pixelSize: 11
                        font.features: { "tnum": 1 }
                    }
                }
            }

            Text {
                visible: entry.failText !== ""
                Layout.fillWidth: true
                Layout.leftMargin: 12
                wrapMode: Text.WordWrap
                text: entry.failText
                color: Theme.accent
                font.pixelSize: 11
            }

            // Password networks: one field. Enter joins.
            RowLayout {
                visible: entry.open && entry.needsForm && !entry.enterprise
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 4
                spacing: 6

                Field {
                    id: pass
                    password: true
                    placeholder: "Password for " + entry.net.name
                    onAccepted: join.activated()
                    onVisibleChanged: if (visible) focusField()
                }

                Tile {
                    id: join
                    label: "Join"
                    implicitHeight: 36
                    armed: pass.text.length >= 8
                    onActivated: {
                        // WPA passwords are 8 to 63 characters; anything else can't work.
                        if (pass.text.length < 8)
                            return
                        root.failure = null
                        entry.net.connectWithPsk(pass.text)
                        pass.text = ""
                        root.picking = ""
                    }
                }
            }

            // Enterprise networks: the sign-in form.
            Loader {
                active: entry.open && entry.needsForm && entry.enterprise
                visible: active
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 4
                sourceComponent: EnterpriseForm {
                    ssid: entry.net.name
                    onJoined: root.picking = ""
                }
            }
        }
    }

    Text {
        visible: Networking.wifiEnabled && root.networks.length === 0
        text: "Looking for networks…"
        color: Theme.fgFaint
        font.pixelSize: 12
    }

    // Hidden networks, static addresses, certificates beyond the form: NetworkManager's
    // own editor.
    Tile {
        Layout.fillWidth: true
        implicitHeight: 32
        label: "Network settings…"
        onActivated: IslandState.run(["nm-connection-editor"])
    }
}
