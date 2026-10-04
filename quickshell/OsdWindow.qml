import QtQuick
import Quickshell
import Quickshell.Wayland

// The volume and brightness indicator: a small pill under the bar, for a moment after
// a key press. It only exists while shown, and its region takes no clicks, so it
// never gets in the way of what's underneath.
PanelWindow {
    id: osd

    required property var screen

    visible: Osd.shown
    screen: osd.screen
    anchors {
        top: true
        left: true
        right: true
    }
    margins.top: 12
    implicitHeight: 60
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    // No input region: clicks pass through to the windows underneath.
    mask: Region {}

    readonly property bool isBrightness: Osd.kind === "brightness"
    readonly property real level: isBrightness ? Brightness.level : Volume.volume

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 240
        height: 46
        radius: 23
        color: Theme.pill
        border.width: 1
        border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)

        Row {
            anchors.centerIn: parent
            spacing: 12

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                kind: osd.isBrightness ? "brightness" : "volume"
                value: osd.level
                muted: !osd.isBrightness && Volume.muted
                font.pixelSize: 16
                color: Theme.fg
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 110
                height: 6
                radius: 3
                color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.6)

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, osd.level))
                    height: parent.height
                    radius: 3
                    color: Theme.accent
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                horizontalAlignment: Text.AlignRight
                text: Math.round(osd.level * 100) + "%"
                color: Theme.fg
                font.pixelSize: 13
            }
        }
    }
}
