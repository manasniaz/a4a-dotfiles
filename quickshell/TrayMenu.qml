import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

// The right-click menu of a tray icon, drawn in the bar's style. The window covers
// the screen but is only shown while a menu is open, so a click anywhere outside
// the menu closes it, and the windows underneath get input the rest of the time.
PanelWindow {
    id: menu

    // The bar's screen, so the menu appears on the same monitor as the icon.
    required property var screen

    visible: false
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Menu entries, top level first. Each submenu entry is pushed on top of the stack,
    // and the back row pops it.
    property var stack: []
    readonly property var current: stack.length > 0 ? stack[stack.length - 1] : null
    // Where the menu hangs from, in screen coordinates: under the icon.
    property real originX: 0
    property real originY: 0

    function show(item, x, y) {
        stack = [item.menu]
        originX = x
        originY = y
        visible = true
    }

    function hide() {
        visible = false
        stack = []
    }

    QsMenuOpener {
        id: opener
        menu: menu.current
    }

    // A click outside the panel closes the menu.
    MouseArea {
        anchors.fill: parent
        onClicked: menu.hide()
    }

    // Escape closes it too.
    Item {
        anchors.fill: parent
        focus: menu.visible
        Keys.onEscapePressed: menu.hide()
    }

    Rectangle {
        id: panel

        x: Math.max(8, Math.min(menu.originX, menu.width - width - 8))
        y: menu.originY + 6
        width: 240
        height: column.implicitHeight + 16
        radius: 14
        color: Theme.pill
        border.width: 1
        border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)

        // Clicks on the panel itself don't reach the close-on-click area behind it.
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 2

            // Back out of a submenu.
            Row {
                visible: menu.stack.length > 1
                Layout.fillWidth: true
                MenuRow {
                    width: parent.width
                    label: "‹  Back"
                    onActivated: menu.stack = menu.stack.slice(0, -1)
                }
            }

            Repeater {
                model: opener.children

                Loader {
                    required property var modelData
                    Layout.fillWidth: true
                    sourceComponent: modelData.isSeparator ? separatorItem : rowItem

                    Component {
                        id: separatorItem

                        Rectangle {
                            height: 1
                            color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)
                        }
                    }

                    Component {
                        id: rowItem

                        MenuRow {
                            label: modelData.text
                            iconSource: modelData.icon
                            enabled: modelData.enabled
                            submenu: modelData.hasChildren
                            onActivated: {
                                if (modelData.hasChildren) {
                                    menu.stack = menu.stack.concat([modelData])
                                } else {
                                    modelData.triggered()
                                    menu.hide()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
