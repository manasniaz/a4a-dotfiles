import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Sign-in for a WPA-Enterprise (802.1X) network such as eduroam: the method, a
// username and password (or a certificate), and the optional fields universities
// hand out. scripts/a4a-wifi-join does the joining; the form goes to it on stdin, so
// the password never appears in a command line. Advanced opens NetworkManager's own
// editor for anything this doesn't cover.
ColumnLayout {
    id: root

    required property string ssid
    // Leaves the form once joined.
    signal joined()

    spacing: 8

    property string eap: "peap"
    property string phase2: "mschapv2"
    property bool more: false
    // Older campus security: forces legacy TLS from the first try (some eduroam
    // networks only speak TLS 1.0). Off, the script still falls back to it on its own.
    property bool legacy: false
    property string status: ""
    property bool failed: false
    readonly property bool busy: joiner.running

    function join() {
        if (busy)
            return
        failed = false
        status = "Connecting…"
        joiner.running = true
    }

    Component.onCompleted: identity.focusField()

    Process {
        id: joiner
        command: [Quickshell.env("HOME") + "/.local/bin/a4a-wifi-join"]
        stdinEnabled: true
        onStarted: {
            const form = {
                ssid: root.ssid, eap: root.eap, phase2: root.phase2,
                identity: identity.text, password: password.text,
                anonymous: anonymous.text, domain: domain.text,
                cert: cert.text, key: key.text, keyPassword: keyPassword.text
            }
            // Only when asked: otherwise the script tries normal TLS first, then this.
            if (root.legacy)
                form.legacy = true
            joiner.write(JSON.stringify(form))
            // Closing stdin is how the script knows the form has all arrived.
            joiner.stdinEnabled = false
        }
        onExited: joiner.stdinEnabled = true

        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const msg = JSON.parse(line)
                    if (msg.ok === true) {
                        // Legacy mode means older campus security was needed; the saved
                        // network keeps it, so it stays quiet about it next time.
                        root.status = msg.legacy ? "Connected (compatibility mode)" : "Connected"
                        root.joined()
                    } else if (msg.ok === false) {
                        root.failed = true
                        root.status = msg.reason
                    } else if (msg.state === "retrying") {
                        // The first try failed; the script is retrying with older TLS,
                        // which some campus networks (eduroam) need.
                        root.status = "Trying compatibility mode…"
                    }
                } catch (e) {
                    // Not one of ours; ignore.
                }
            }
        }
    }

    // Method: PEAP and TTLS sign in with a username and password (eduroam uses one of
    // them); TLS uses a certificate file instead.
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: [
                { key: "peap", label: "PEAP" },
                { key: "ttls", label: "TTLS" },
                { key: "tls", label: "Certificate" }
            ]

            Tile {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 30
                label: modelData.label
                armed: root.eap === modelData.key
                onActivated: {
                    root.eap = modelData.key
                    if (modelData.key === "peap")
                        root.phase2 = "mschapv2"
                }
            }
        }
    }

    Field {
        id: identity
        placeholder: root.eap === "tls" ? "Identity (usually your email)" : "Username (e.g. you@university.edu)"
        onAccepted: root.eap === "tls" ? cert.focusField() : password.focusField()
    }

    Field {
        id: password
        visible: root.eap !== "tls"
        password: true
        placeholder: "Password"
        onAccepted: root.join()
    }

    Field {
        id: cert
        visible: root.eap === "tls"
        placeholder: "Client certificate file (full path)"
        onAccepted: key.focusField()
    }

    Field {
        id: key
        visible: root.eap === "tls"
        placeholder: "Private key file (full path)"
        onAccepted: keyPassword.focusField()
    }

    Field {
        id: keyPassword
        visible: root.eap === "tls"
        password: true
        placeholder: "Private key password (if it has one)"
        onAccepted: root.join()
    }

    // The rest only when asked for: most networks need none of it.
    Text {
        text: root.more ? "Fewer options" : "More options (domain, anonymous identity…)"
        color: Theme.accent
        font.pixelSize: 11

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.more = !root.more
        }
    }

    ColumnLayout {
        visible: root.more
        Layout.fillWidth: true
        spacing: 8

        // TTLS lets the inner sign-in vary; PEAP is MSCHAPv2 almost everywhere.
        RowLayout {
            visible: root.eap === "ttls"
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Inner"
                color: Theme.fgDim
                font.pixelSize: 12
                Layout.preferredWidth: 44
            }

            Repeater {
                model: [{ key: "mschapv2", label: "MSCHAPv2" }, { key: "pap", label: "PAP" }]

                Tile {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 28
                    label: modelData.label
                    armed: root.phase2 === modelData.key
                    onActivated: root.phase2 = modelData.key
                }
            }
        }

        Field {
            id: domain
            placeholder: "Server domain, e.g. university.edu (recommended)"
        }

        Field {
            id: anonymous
            visible: root.eap !== "tls"
            placeholder: "Anonymous identity, e.g. anonymous@university.edu"
        }

        OptionRow {
            label: "Older campus security"
            hint: "Turn on if it won't connect (some eduroam networks need TLS 1.0)."
            checked: root.legacy
            onToggled: root.legacy = !root.legacy
        }
    }

    // Without a domain the server can't be checked, which is what lets a fake
    // access point collect the password. Said once, plainly, not as a blocker.
    Text {
        visible: domain.text === "" && root.eap !== "tls"
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: "Without a server domain, the network's identity isn't checked. Your university's IT page lists it."
        color: Theme.fgFaint
        font.pixelSize: 11
    }

    Text {
        visible: root.status !== ""
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: root.status
        color: root.failed ? Theme.accent : Theme.fgDim
        font.pixelSize: 12
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Tile {
            implicitHeight: 32
            label: "Advanced…"
            onActivated: IslandState.run(["nm-connection-editor"])
        }

        Item { Layout.fillWidth: true }

        Tile {
            implicitHeight: 32
            implicitWidth: 96
            label: root.busy ? "Connecting…" : "Connect"
            armed: !root.busy
            onActivated: root.join()
        }
    }
}
