import QtQuick
import QtQuick.Layouts

// CPU and RAM meters for the status pill.
RowLayout {
    spacing: 14

    Meter {
        label: "CPU"
        value: Stats.cpu
        valueText: Math.round(Stats.cpu * 100) + "%"
        fillColor: Stats.cpu > 0.85 ? Theme.fg : Theme.accent
    }

    Meter {
        label: "RAM"
        value: Stats.ram
        valueText: Math.round(Stats.ram * 100) + "%"
        fillColor: Stats.ram > 0.85 ? Theme.fg : Theme.accent
    }
}
