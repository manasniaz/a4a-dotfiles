import QtQuick
import QtQuick.Layouts

// Laptop battery for the system card: a battery glyph, a bar and the percentage.
// Hidden on machines without a battery.
RowLayout {
    visible: Stats.batteryPresent
    spacing: 8

    Icon {
        kind: "battery"
        value: Stats.batteryPresent ? Stats.battery.percentage : 0
        charging: Stats.charging
        color: Theme.fg
    }

    Rectangle {
        implicitWidth: 42
        implicitHeight: 6
        radius: 3
        color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.6)

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0, Math.min(1, Stats.batteryPresent ? Stats.battery.percentage : 0))
            radius: 3
            color: Theme.accent

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        text: Math.round((Stats.batteryPresent ? Stats.battery.percentage : 0) * 100) + "%"
        color: Theme.fg
        font.pixelSize: 12
        Layout.minimumWidth: 34
    }
}
