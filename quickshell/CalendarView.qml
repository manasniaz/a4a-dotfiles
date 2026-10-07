import QtQuick
import QtQuick.Layouts
import Quickshell

// A month calendar, for the time and date in the closed pill. Today is filled in
// with the accent; the arrows step through other months.
ColumnLayout {
    id: root

    spacing: 10

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    property int monthOffset: 0

    readonly property date today: clock.date
    readonly property date shownMonth: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)

    // Monday-first, the way most calendars are laid out in Europe.
    readonly property int leadingBlanks: (shownMonth.getDay() + 6) % 7
    readonly property int daysInMonth: new Date(shownMonth.getFullYear(), shownMonth.getMonth() + 1, 0).getDate()

    DetailHeader {
        title: "Calendar"

        Tile {
            label: "Today"
            implicitWidth: 56
            implicitHeight: 32
            onActivated: root.monthOffset = 0
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Tile {
            label: "‹"
            implicitWidth: 36
            implicitHeight: 30
            onActivated: root.monthOffset -= 1
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(root.shownMonth, "MMMM yyyy")
            color: Theme.fg
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Tile {
            label: "›"
            implicitWidth: 36
            implicitHeight: 30
            onActivated: root.monthOffset += 1
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            Text {
                required property string modelData
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.fgFaint
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }

        Repeater {
            // Only as many weeks as the month needs, so there's no empty row.
            model: Math.ceil((root.leadingBlanks + root.daysInMonth) / 7) * 7

            Rectangle {
                required property int index
                readonly property int day: index - root.leadingBlanks + 1
                readonly property bool inMonth: day >= 1 && day <= root.daysInMonth
                readonly property bool isToday: inMonth
                    && root.monthOffset === 0 && day === root.today.getDate()

                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: 9
                color: isToday ? Theme.accent : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: parent.inMonth ? parent.day : ""
                    color: parent.isToday ? Theme.bg : (parent.inMonth ? Theme.fg : Theme.muted)
                    font.pixelSize: 12
                    font.weight: parent.isToday ? Font.DemiBold : Font.Normal
                }
            }
        }
    }
}
