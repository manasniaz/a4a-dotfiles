import QtQuick
import QtQuick.Layouts
import Quickshell

// One thing the closed pill shows: a clock, a calendar date, the track, CPU and
// RAM, battery, Wi-Fi, Bluetooth, or the download and upload speed. Each item has a
// small glyph where one fits, and a click opens its own screen in the island.
// Items with nothing to show hide themselves, and so does their separator.
Item {
    id: root

    required property string modelData
    required property int index

    readonly property string key: modelData

    implicitWidth: content.implicitWidth
    implicitHeight: 38

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function pct(v) {
        return Math.round(v * 100) + "%"
    }

    readonly property string text: {
        switch (key) {
        case "time": return Qt.formatTime(clock.date, "HH:mm")
        case "date": return Qt.formatDate(clock.date, "ddd d MMM")
        case "track": return IslandState.player ? IslandState.trackTitle(IslandState.player) : ""
        case "cpu": return "CPU " + pct(Stats.cpu)
        case "ram": return "RAM " + pct(Stats.ram)
        case "battery": return Stats.batteryPresent ? pct(Stats.battery.percentage) : ""
        case "wifi": return Stats.wifiOn ? (Stats.wifiNet ? Stats.wifiPercent + "%" : "") : "Off"
        case "download": return Stats.fmtRate(Stats.downBps)
        case "upload": return Stats.fmtRate(Stats.upBps)
        case "volume": return Volume.hasSink ? Volume.percent + "%" : ""
        }
        return ""
    }

    readonly property string iconKind: {
        switch (key) {
        // Time and date need no glyph: the words already say what they are.
        case "battery": return Stats.batteryPresent ? "battery" : ""
        case "wifi": return "wifi"
        case "bluetooth": return "bluetooth"
        case "download": return "down"
        case "upload": return "up"
        case "volume": return "volume"
        }
        return ""
    }

    // Which screen a click opens: the one named for this item, nothing else.
    readonly property string targetView: {
        switch (key) {
        case "time": return "clock"
        case "date": return "calendar"
        case "track": return "media"
        case "battery":
        case "cpu":
        case "ram": return "system"
        case "bluetooth": return "bluetooth"
        case "download":
        case "upload": return "network"
        case "volume": return "sound"
        }
        return "wifi"
    }

    // The glyph's own reading: the signal for Wi-Fi, the charge for the battery.
    readonly property string glyphKind: key === "wifi" && !Stats.wifiOn ? "wifi-off" : iconKind
    readonly property real glyphValue: {
        if (key === "wifi")
            return Stats.wifiNet ? Stats.wifiNet.signalStrength : 0
        if (key === "battery")
            return Stats.batteryPresent ? Stats.battery.percentage : 0
        if (key === "volume")
            return Volume.volume
        return 1
    }

    readonly property color iconColor: {
        if (key === "bluetooth")
            return !Stats.btOn ? Theme.muted : (Stats.btConnected > 0 ? Theme.accent : Theme.fg)
        if (key === "wifi")
            return Stats.wifiOn ? Theme.fg : Theme.muted
        if (key === "volume")
            return Volume.muted ? Theme.muted : Theme.fg
        return Theme.fg
    }

    visible: text !== "" || iconKind !== ""

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandState.openTo(root.targetView)
        // Scroll over the volume to turn it up or down, a step at a time.
        onWheel: (wheel) => {
            if (root.key !== "volume" || wheel.angleDelta.y === 0)
                return
            Volume.setVolume(Volume.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
        }
    }

    RowLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        // Dot between items, not before the first one.
        Rectangle {
            visible: true
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 3
            Layout.rightMargin: 3
            implicitWidth: 3
            implicitHeight: 3
            radius: 1.5
            color: Theme.muted
        }

        Icon {
            visible: root.iconKind !== ""
            Layout.alignment: Qt.AlignVCenter
            kind: root.glyphKind
            value: root.glyphValue
            charging: Stats.charging
            muted: Volume.muted
            color: root.iconColor
            font.pixelSize: 16
        }

        Text {
            visible: root.text !== ""
            Layout.alignment: Qt.AlignVCenter
            text: root.text
            color: Theme.fg
            font.pixelSize: 13
        }
    }
}
