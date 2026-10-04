import QtQuick
import QtQuick.Layouts
import Quickshell

// The screen behind the time in the closed pill: the time to the second, and the date.
ColumnLayout {
    id: root

    spacing: 14

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    DetailHeader {
        title: "Clock"
        backTo: "home"
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 8
        text: Qt.formatTime(clock.date, "HH:mm:ss")
        color: Theme.fg
        font.pixelSize: 44
        font.weight: Font.DemiBold
        font.family: "JetBrainsMono Nerd Font Mono"
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
        color: Theme.muted
        font.pixelSize: 13
    }
}
