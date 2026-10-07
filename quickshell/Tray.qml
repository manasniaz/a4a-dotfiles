import QtQuick
import Quickshell.Services.SystemTray

// Status-notifier icons. Left click activates the app; right click opens its menu
// in TrayMenu, placed under the icon. barLeft and barTop locate the bar's window on
// the screen, so the menu lines up with the icon.
Row {
    id: root

    required property var menu
    required property real barLeft
    required property real barTop

    spacing: 0
    visible: repeater.count > 0

    Repeater {
        id: repeater
        model: SystemTray.items

        Item {
            id: slot
            required property var modelData

            width: 28
            height: 28

            Hover {
                hovered: mouse.containsMouse
                pressed: mouse.pressed
            }

            Image {
                anchors.centerIn: parent
                source: slot.modelData.icon
                width: 16
                height: 16
                sourceSize.width: 32
                sourceSize.height: 32
                fillMode: Image.PreserveAspectFit
                smooth: true
                scale: mouse.pressed ? 0.9 : 1

                Behavior on scale { NumberAnimation { duration: 100 } }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (!slot.modelData.hasMenu)
                            return
                        const p = slot.mapToItem(null, 0, slot.height + 4)
                        root.menu.show(slot.modelData, root.barLeft + p.x, root.barTop + p.y)
                    } else {
                        slot.modelData.activate()
                    }
                }
            }
        }
    }
}
