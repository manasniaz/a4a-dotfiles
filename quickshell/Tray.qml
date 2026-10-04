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

    spacing: 8
    visible: repeater.count > 0

    Repeater {
        id: repeater
        model: SystemTray.items

        Image {
            required property var modelData

            source: modelData.icon
            width: 16
            height: 16
            sourceSize.width: 16
            sourceSize.height: 16
            fillMode: Image.PreserveAspectFit
            smooth: true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (!parent.modelData.hasMenu)
                            return
                        const p = parent.mapToItem(null, 0, parent.height)
                        root.menu.show(parent.modelData, root.barLeft + p.x, root.barTop + p.y)
                    } else {
                        parent.modelData.activate()
                    }
                }
            }
        }
    }
}
