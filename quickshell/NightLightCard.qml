import QtQuick
import QtQuick.Layouts
import Quickshell

// The night light on the island's home page: one switch for the schedule.
Card {
    title: "Night light"

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            Layout.fillWidth: true
            text: "Warm from " + String(NightLight.warmFrom).padStart(2, "0") + ":00 to "
                + String(NightLight.warmUntil).padStart(2, "0") + ":00"
            color: Theme.fg
            font.pixelSize: 13
        }

        Switch {
            checked: NightLight.enabled
            onToggled: NightLight.setEnabled(!NightLight.enabled)
        }
    }
}
