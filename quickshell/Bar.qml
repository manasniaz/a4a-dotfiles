import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

// A floating top bar made of three pills: workspaces on the left, the island in
// the centre, and status on the right.
//
// The window is always the same height. Growing and shrinking it when the island
// opens made the compositor relayout and repaint the whole bar, which showed up
// as a flicker. Instead the window reserves room for the open island from the
// start, and its input mask limits clicks to whatever is currently visible.
PanelWindow {
    id: bar

    readonly property int pillHeight: 38
    // A true fullscreen window hides the bar, as the Windows taskbar does. A maximised
    // one (SUPER+M) is fullscreen 1 in Hyprland, and keeps the bar. The island keeps
    // the bar up while it's open, so its keybind still works over a fullscreen app.
    readonly property bool fullscreen: FullscreenState.trueFullscreen
    readonly property int edge: 4
    readonly property int openHeight: IslandState.barSpan - bar.edge

    visible: !bar.fullscreen || IslandState.open
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: bar.edge
        left: 12
        right: 12
    }
    implicitHeight: bar.openHeight
    // Reserve only the pill row, so tiled windows stop under the bar and not behind it.
    exclusiveZone: bar.pillHeight + bar.edge
    color: "transparent"

    // Above the outside-click catcher, so the island and its pills get the clicks.
    WlrLayershell.layer: WlrLayer.Overlay
    // Only while the island is open: it needs the keyboard for its password field.
    // OnDemand, so the bar gets focus when clicked and gives it back when closed.
    WlrLayershell.keyboardFocus: IslandState.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Only the visible pills take clicks. The rest of the window passes input
    // through to the windows below.
    // Closed: only the pills take clicks, the rest passes through to the windows
    // below. Open: the whole window takes clicks, so the panel's buttons get them.
    // Clicks outside the panel still reach the outside-click catcher and close it.
    mask: IslandState.open ? openMask : closedMask

    Region {
        id: closedMask
        Region { item: workspacePill }
        Region { item: island }
        Region { item: statusPill }
    }

    Region {
        id: openMask
        x: 0
        y: 0
        width: bar.width
        height: bar.height
    }

    // The right-click menu of the tray icons. One per bar, on this bar's screen.
    TrayMenu {
        id: trayMenu
        screen: bar.screen
    }

    Item {
        anchors.fill: parent

        // Background of the open window: a click on empty bar space closes the
        // island. The pills and the panel sit above it and take their own clicks.
        MouseArea {
            anchors.fill: parent
            enabled: IslandState.open
            onClicked: IslandState.close()
        }

        Rectangle {
            id: workspacePill
            anchors.left: parent.left
            anchors.top: parent.top
            height: bar.pillHeight
            width: workspaces.implicitWidth + 14
            radius: height / 2
            color: Theme.pill
            border.width: 1
            border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)

            Workspaces {
                id: workspaces
                anchors.centerIn: parent
            }

            // Scroll anywhere on the pill to move to the next workspace that exists,
            // as SUPER+scroll does (ML4W). It takes no clicks, so the buttons still get them.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y === 0)
                        return
                    Hyprland.dispatch(wheel.angleDelta.y < 0
                        ? "hl.dsp.focus({ workspace = 'e+1' })"
                        : "hl.dsp.focus({ workspace = 'e-1' })")
                }
            }
        }

        Island {
            id: island
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            pillHeight: bar.pillHeight
        }

        Rectangle {
            id: statusPill
            anchors.right: parent.right
            anchors.top: parent.top
            // Only there when a tray icon is, so an empty pill doesn't sit at the edge.
            visible: SystemTray.items.values.length > 0
            height: bar.pillHeight
            width: status.implicitWidth + 28
            radius: height / 2
            color: Theme.pill
            border.width: 1
            border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)

            RowLayout {
                id: status
                anchors.centerIn: parent
                spacing: 14

                Tray {
                    menu: trayMenu
                    barLeft: bar.margins.left
                    barTop: bar.margins.top
                }
            }
        }
    }
}
