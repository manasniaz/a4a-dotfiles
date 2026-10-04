import QtQuick
import Quickshell.Hyprland

// One pill per workspace Hyprland currently has. The focused one is filled with
// the accent, so it reads at a glance without a border.
Row {
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            required property var modelData

            readonly property bool focused: modelData.active

            width: Math.max(22, label.implicitWidth + 12)
            height: 18
            radius: 4
            color: focused ? Theme.accent : "transparent"
            border.width: 1
            border.color: focused ? Theme.accent : Theme.muted

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.name
                color: parent.focused ? Theme.bg : Theme.fg
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                // Lua dispatchers, same form as the binds in hypr/binds.lua.
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                // Let the wheel through, so scrolling anywhere on the pill changes desktop.
                onWheel: (wheel) => { wheel.accepted = false }
            }
        }
    }
}
