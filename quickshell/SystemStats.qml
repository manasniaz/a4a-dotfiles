import QtQuick
import QtQuick.Layouts

// CPU and RAM meters side by side, each taking half the width it's given.
RowLayout {
    spacing: 14

    Meter {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        label: "CPU"
        value: Stats.cpu
        valueText: Math.round(Stats.cpu * 100) + "%"
        fillColor: Stats.cpu > 0.85 ? Theme.fg : Theme.accent
    }

    Meter {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        label: "RAM"
        value: Stats.ram
        valueText: Math.round(Stats.ram * 100) + "%"
        fillColor: Stats.ram > 0.85 ? Theme.fg : Theme.accent
    }
}
