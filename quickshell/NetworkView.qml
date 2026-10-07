import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

// The screen behind the speed in the closed pill: download and upload right now,
// the last minute of downloads as a chart, and the Wi-Fi link they're going over.
ColumnLayout {
    id: root

    spacing: 10

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property real peak: Math.max(1024, ...Stats.downHistory)

    DetailHeader {
        title: "Network"
    }

    Card {
        title: "Right now"

        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Download"; color: Theme.fgFaint; font.pixelSize: 11 }
                Text { text: Stats.fmtRate(Stats.downBps); color: Theme.fg; font.pixelSize: 20; font.weight: Font.DemiBold }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Upload"; color: Theme.fgFaint; font.pixelSize: 11 }
                Text { text: Stats.fmtRate(Stats.upBps); color: Theme.fg; font.pixelSize: 20; font.weight: Font.DemiBold }
            }
        }
    }

    Card {
        title: "Download, last minute"

        // One bar per second, scaled to the busiest second in the window.
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            spacing: 2

            Repeater {
                model: 60

                Item {
                    required property int index
                    readonly property real sample: index < Stats.downHistory.length
                        ? Stats.downHistory[index] : 0

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(1, parent.height * parent.sample / root.peak)
                        radius: 1
                        color: Theme.accent
                    }
                }
            }
        }
    }

    Card {
        title: "Connection"

        Text {
            Layout.fillWidth: true
            text: root.wifi === null ? "No Wi-Fi adapter"
                : (Stats.wifiNet ? "Wi-Fi: " + Stats.wifiNet.name + "  ·  " + Stats.wifiPercent + "% signal"
                    : (Stats.wifiOn ? "Wi-Fi is on, not connected" : "Wi-Fi is off"))
            color: Theme.fg
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }
    }
}
