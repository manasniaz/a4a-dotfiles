import QtQuick
import QtQuick.Layouts

// The screen behind the volume in the closed pill: the level, mute, and which
// output everything plays through. Pick the laptop speaker here to use it.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "Sound"
    }

    Card {
        title: "Volume"

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Tile {
                implicitWidth: 40
                implicitHeight: 34
                onActivated: Volume.toggleMute()

                Icon {
                    anchors.centerIn: parent
                    kind: "volume"
                    value: Volume.volume
                    muted: Volume.muted
                    font.pixelSize: 16
                    color: Theme.fg
                }
            }

            Slider {
                Layout.fillWidth: true
                value: Volume.volume
                onMoved: (v) => Volume.setVolume(v)
            }

            Text {
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
                text: Volume.percent + "%"
                color: Theme.fg
                font.pixelSize: 13
            }
        }
    }

    Card {
        title: "Output"

        Text {
            Layout.fillWidth: true
            visible: Volume.sinks.length === 0
            text: "No audio output found."
            color: Theme.fgFaint
            font.pixelSize: 12
        }

        Repeater {
            model: Volume.sinks

            Rectangle {
                required property var modelData
                readonly property bool isDefault: Volume.sink !== null && modelData.id === Volume.sink.id

                Layout.fillWidth: true
                implicitHeight: 38
                radius: 9
                color: isDefault ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    : (rowMouse.containsMouse ? Qt.lighter(Theme.card, 1.15) : "transparent")

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Volume.makeDefault(parent.modelData)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: Volume.label(parent.parent.modelData)
                        color: parent.parent.isDefault ? Theme.accent : Theme.fg
                        font.pixelSize: 13
                    }

                    Text {
                        visible: parent.parent.isDefault
                        text: "in use"
                        color: Theme.fgFaint
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
