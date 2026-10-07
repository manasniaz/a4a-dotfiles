import QtQuick
import QtQuick.Layouts

// The screen behind the CPU, RAM, battery and network items in the closed pill.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "System"
    }

    Card {
        title: "Processor"
        Meter {
            Layout.fillWidth: true
            label: "CPU"
            value: Stats.cpu
            valueText: Math.round(Stats.cpu * 100) + "%"
            fillColor: Stats.cpu > 0.85 ? Theme.fg : Theme.accent
        }
    }

    Card {
        title: "Memory"
        Meter {
            Layout.fillWidth: true
            label: "RAM"
            value: Stats.ram
            valueText: Math.round(Stats.ram * 100) + "%"
            fillColor: Stats.ram > 0.85 ? Theme.fg : Theme.accent
        }
    }

    Card {
        title: "Battery"
        visible: Stats.batteryPresent
        Battery {}
    }

    Card {
        title: "Network"

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Icon { kind: "down"; font.pixelSize: 16; color: Theme.fg }
            Text { text: Stats.fmtRate(Stats.downBps); color: Theme.fg; font.pixelSize: 13 }
            Item { Layout.fillWidth: true }
            Icon { kind: "up"; font.pixelSize: 16; color: Theme.fg }
            Text { text: Stats.fmtRate(Stats.upBps); color: Theme.fg; font.pixelSize: 13 }
        }
    }
}
