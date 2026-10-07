import QtQuick
import QtQuick.Layouts

// A device asking to pair, in the control centre (opened by the request itself, like
// Windows' "Add a device?" prompt). The code is large so it's easy to compare with
// the device's screen. Enter pairs, Escape declines; so does closing the panel.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var req: Pairing.request
    readonly property string kind: req ? req.kind : ""
    readonly property bool needsInput: kind === "pin" || kind === "passkey"

    // "123456" reads as "123 456", like a phone shows it.
    function grouped(code) {
        return code.length === 6 ? code.slice(0, 3) + " " + code.slice(3) : code
    }

    function pair() {
        if (!req)
            return
        if (needsInput && field.text === "")
            return
        Pairing.answer(true, needsInput ? field.text : "")
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            Pairing.answer(false, "")
            return true
        }
        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && kind !== "display") {
            pair()
            return true
        }
        return false
    }

    Component.onCompleted: if (needsInput) field.focusField()

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: 12
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)

            Icon {
                anchors.centerIn: parent
                kind: "bluetooth"
                color: Theme.accent
                font.pixelSize: 20
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: root.kind === "service" ? "Connection request" : "Pairing request"
                color: Theme.fgFaint
                font.pixelSize: 11
            }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.req ? root.req.device : "No request"
                color: Theme.fg
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
        }
    }

    Card {
        visible: root.req !== null

        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Theme.fgDim
            font.pixelSize: 12
            text: {
                switch (root.kind) {
                case "confirm": return "Check that this code matches the one on the device."
                case "authorize": return "This device wants to pair with this computer."
                case "service": return "This device wants to connect (" + (root.req ? root.req.code : "") + ")."
                case "pin": return "Type the device's PIN. Most keyboards and mice without a screen use 0000."
                case "passkey": return "Type the 6-digit passkey shown on the device."
                case "display": return "Type this code on the device, then press Enter on it."
                }
                return ""
            }
        }

        Text {
            visible: root.kind === "confirm" || root.kind === "display"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            text: root.req ? root.grouped(root.req.code) : ""
            color: Theme.fg
            font.pixelSize: 34
            font.weight: Font.DemiBold
            font.letterSpacing: 2
            font.features: { "tnum": 1 }
        }

        // Keyboards report each digit as it's typed: one dot per digit.
        Row {
            visible: root.kind === "display" && root.req !== null && root.req.code.length > 0
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Repeater {
                model: root.req ? root.req.code.length : 0

                Rectangle {
                    required property int index
                    width: 8
                    height: 8
                    radius: 4
                    color: root.req && index < root.req.entered ? Theme.accent : Theme.line
                }
            }
        }

        Field {
            id: field
            visible: root.needsInput
            digits: true
            maxLength: root.kind === "passkey" ? 6 : 16
            placeholder: root.kind === "passkey" ? "6-digit passkey" : "PIN"
            text: root.kind === "pin" ? "0000" : ""
            onAccepted: root.pair()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2
            spacing: 6

            Tile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 36
                label: root.kind === "display" ? "Cancel" : "Decline"
                onActivated: Pairing.answer(false, "")
            }
            Tile {
                visible: root.kind !== "display"
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 36
                label: root.kind === "service" || root.kind === "authorize" ? "Allow" : "Pair"
                armed: true
                onActivated: root.pair()
            }
        }
    }
}
