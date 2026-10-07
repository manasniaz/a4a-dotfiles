import QtQuick
import QtQuick.Layouts

// One setting: a label, an optional hint underneath, and a switch on the right.
RowLayout {
    id: root

    property string label
    property string hint: ""
    property bool checked: false
    signal toggled()

    Layout.fillWidth: true
    spacing: 10

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 1

        // fillWidth here, not only on the column: a layout is never wider than its
        // children allow, so without it the switch trailed the label.
        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.label
            color: Theme.fg
            font.pixelSize: 13
        }

        Text {
            visible: root.hint !== ""
            text: root.hint
            color: Theme.fgFaint
            font.pixelSize: 11
        }
    }

    Switch {
        checked: root.checked
        onToggled: root.toggled()
    }
}
