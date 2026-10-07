import QtQuick
import Quickshell
import Quickshell.Wayland

// The volume and brightness indicator: a small pill under the bar, for a moment after
// a key press. It only exists while shown, and its region takes no clicks, so it
// never gets in the way of what's underneath.
PanelWindow {
    id: osd

    required property var screen

    // Stays up until the fade-out has finished.
    visible: Osd.shown || card.opacity > 0
    screen: osd.screen
    anchors {
        top: true
        left: true
        right: true
    }
    // exclusiveZone 0 keeps it clear of the bar's reserved strip, so this margin is
    // only the gap under the bar. With the bar hidden (fullscreen) it sits at the top.
    margins.top: 10
    implicitHeight: 70
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    // No input region: clicks pass through to the windows underneath.
    mask: Region {}

    readonly property bool isBrightness: Osd.kind === "brightness"
    readonly property real level: isBrightness ? Brightness.level : Volume.volume

    BarPill {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: Osd.shown ? 0 : -6
        width: 240
        height: 46
        opacity: Osd.shown ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

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

                    Behavior on width { NumberAnimation { duration: 90 } }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                horizontalAlignment: Text.AlignRight
                text: Math.round(osd.level * 100) + "%"
                color: Theme.fg
                font.pixelSize: 13
                font.features: { "tnum": 1 }
            }
        }
    }
}
