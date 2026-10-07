import QtQuick
import QtQuick.Layouts
import Quickshell

// One reading on the bar: the clock, the date, the track, CPU, RAM, network speed,
// Wi-Fi, Bluetooth, volume or battery. Where it sits is set in IslandState.choices.
//
// How loud each one is follows how often it's looked at. The time is the heaviest
// text on the bar. The date and track are dimmer. CPU, RAM and speeds are small and
// quiet unless something is wrong (a reading over 85% turns accent). Status glyphs
// are full colour only while they mean something (Bluetooth hides when it's off).
//
// A click opens the item's own screen in the island. Items with nothing to show
// hide themselves.
Item {
    id: root

    required property string modelData
    readonly property string key: modelData

    implicitWidth: content.implicitWidth + 2 * pad
    implicitHeight: 28

    readonly property int pad: key === "time" || key === "date" ? 6 : 7

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function pct(v) {
        return Math.round(v * 100) + "%"
    }

    readonly property var player: IslandState.player
    readonly property bool batteryLow: Stats.batteryPresent && !Stats.charging && Stats.battery.percentage <= 0.2

    readonly property string text: {
        switch (key) {
        case "time": return Qt.formatTime(clock.date, "HH:mm")
        case "date": return Qt.formatDate(clock.date, "ddd d MMM")
        // Only while something plays: a paused player isn't news.
        case "track": return player && player.isPlaying ? IslandState.trackTitle(player) : ""
        case "cpu": return pct(Stats.cpu)
        case "ram": return pct(Stats.ram)
        case "battery": return Stats.batteryPresent ? pct(Stats.battery.percentage) : ""
        case "download": return Stats.fmtRate(Stats.downBps)
        case "upload": return Stats.fmtRate(Stats.upBps)
        }
        return ""
    }

    // Small caps label in front of a number, for the readings that have no glyph.
    readonly property string label: key === "cpu" ? "CPU" : key === "ram" ? "RAM" : ""

    readonly property string glyph: {
        switch (key) {
        case "track": return "music"
        case "battery": return Stats.batteryPresent ? "battery" : ""
        case "wifi": return !Stats.wifiOn ? "wifi-off" : (Stats.wifiNet ? "wifi" : "wifi-none")
        case "bluetooth": return Stats.btOn ? (Stats.btConnected > 0 ? "bluetooth-connected" : "bluetooth") : ""
        case "download": return "down"
        case "upload": return "up"
        case "volume": return Volume.hasSink ? "volume" : ""
        }
        return ""
    }

    readonly property real glyphValue: {
        if (key === "wifi")
            return Stats.wifiNet ? Stats.wifiNet.signalStrength : 0
        if (key === "battery")
            return Stats.batteryPresent ? Stats.battery.percentage : 0
        if (key === "volume")
            return Volume.volume
        return 1
    }

    readonly property color glyphColor: {
        switch (key) {
        case "track": return Theme.accent
        case "bluetooth": return Stats.btConnected > 0 ? Theme.accent : Theme.fg
        case "wifi": return Stats.wifiNet ? Theme.fg : Theme.fgDim
        case "volume": return Volume.muted ? Theme.fgDim : Theme.fg
        case "battery": return root.batteryLow ? Theme.accent : Theme.fg
        case "download":
        case "upload": return Theme.fgDim
        }
        return Theme.fg
    }

    readonly property color textColor: {
        switch (key) {
        case "time": return Theme.fg
        case "battery": return root.batteryLow ? Theme.accent : Theme.fg
        case "cpu": return Stats.cpu > 0.85 ? Theme.accent : Theme.fgDim
        case "ram": return Stats.ram > 0.85 ? Theme.accent : Theme.fgDim
        }
        return Theme.fgDim
    }

    readonly property int textSize: key === "time" ? 14 : (key === "battery" || key === "date" || key === "track" ? 12 : 11)

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

    // The track's note glyph means nothing without the title, so it needs its text.
    visible: key === "track" ? text !== "" : (text !== "" || glyph !== "")

    Hover {
        hovered: mouse.containsMouse
        pressed: mouse.pressed
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandState.openTo(root.targetView)
        // Scroll over the volume to turn it up or down, a step at a time. Anything
        // else lets the wheel through to the pill.
        onWheel: (wheel) => {
            if (root.key !== "volume" || wheel.angleDelta.y === 0) {
                wheel.accepted = false
                return
            }
            Volume.setVolume(Volume.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
            Osd.show("volume")
        }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: root.label !== "" ? 5 : 4
        scale: mouse.pressed ? 0.96 : 1

        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        WifiGlyph {
            visible: root.key === "wifi"
            Layout.alignment: Qt.AlignVCenter
            value: root.glyphValue
            off: !Stats.wifiOn
            color: root.glyphColor
        }

        Icon {
            visible: root.glyph !== "" && root.key !== "wifi"
            Layout.alignment: Qt.AlignVCenter
            kind: root.glyph
            value: root.glyphValue
            charging: Stats.charging
            muted: Volume.muted
            color: root.glyphColor
            font.pixelSize: root.key === "track" || root.key === "download" || root.key === "upload" ? 13 : 16

            Behavior on color { ColorAnimation { duration: 160 } }
        }

        Text {
            visible: root.label !== ""
            Layout.alignment: Qt.AlignVCenter
            text: root.label
            color: Theme.fgFaint
            font.pixelSize: 9
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Text {
            visible: root.text !== ""
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: root.key === "track" ? 220 : -1
            elide: Text.ElideRight
            text: root.text
            color: root.textColor
            font.pixelSize: root.textSize
            font.weight: root.key === "time" ? Font.DemiBold : (root.key === "battery" ? Font.Medium : Font.Normal)
            // Fixed-width digits, so the clock and the numbers don't jiggle as they change.
            font.features: { "tnum": 1 }

            Behavior on color { ColorAnimation { duration: 160 } }
        }
    }
}
