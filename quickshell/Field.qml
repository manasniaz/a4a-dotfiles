import QtQuick
import QtQuick.Layouts

// A one-line text field in the panel's style: a placeholder while empty, an accent
// edge while focused, and an eye to show a password. Enter fires `accepted`, Tab
// moves to the next field (Qt's own focus chain).
Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property bool password: false
    property bool showPassword: false
    // Only digits, for PINs and passkeys.
    property bool digits: false
    property int maxLength: 32767
    property alias input: input
    signal accepted()

    Layout.fillWidth: true
    implicitHeight: 36
    radius: 10
    color: Theme.bg
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.line

    Behavior on border.color { ColorAnimation { duration: 120 } }

    function focusField() {
        input.forceActiveFocus()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: root.password ? 4 : 12
        spacing: 4

        TextInput {
            id: input
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            echoMode: root.password && !root.showPassword ? TextInput.Password : TextInput.Normal
            inputMethodHints: root.digits ? Qt.ImhDigitsOnly : Qt.ImhNone
            validator: root.digits ? digitsOnly : null
            maximumLength: root.maxLength
            color: Theme.fg
            selectionColor: Theme.accent
            selectedTextColor: Theme.bg
            font.pixelSize: 13
            clip: true
            activeFocusOnTab: true
            onAccepted: root.accepted()

            RegularExpressionValidator {
                id: digitsOnly
                regularExpression: /[0-9]*/
            }

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: input.text === ""
                text: root.placeholder
                color: Theme.fgFaint
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }

        // Show or hide the password.
        Rectangle {
            visible: root.password
            implicitWidth: 28
            implicitHeight: 28
            radius: 8
            color: eye.containsMouse ? Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.08) : "transparent"

            Icon {
                anchors.centerIn: parent
                kind: root.showPassword ? "eye-off" : "eye"
                color: Theme.fgDim
                font.pixelSize: 15
            }

            MouseArea {
                id: eye
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.showPassword = !root.showPassword
            }
        }
    }
}
