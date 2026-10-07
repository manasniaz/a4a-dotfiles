import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

// A floating top bar of three pills:
//   left    workspaces, then the focused window's title
//   centre  the island: the clock and date, the track while one plays
//   right   tray, then quiet readings (CPU, RAM), then status glyphs
//
// Spacing: the pills sit `edge` px from the screen edges, the same as Hyprland's
// gaps_out, so they line up with the tiled windows below. Inside a pill, everything
// clickable is inset by the same amount top, bottom and sides, so hover pills sit
// evenly in their pill.
//
// The window is always the same height. Growing and shrinking it when the island
// opens made the compositor relayout and repaint the whole bar, which showed up
// as a flicker. Instead the window reserves room for the open island from the
// start, and its input mask limits clicks to whatever is currently visible.
PanelWindow {
    id: bar

    readonly property int pillHeight: 38
    // hypr/look.lua: general.gaps_out
    readonly property int edge: 6
    // A true fullscreen window hides the bar, as the Windows taskbar does. A maximised
    // one (SUPER+M) is fullscreen 1 in Hyprland, and keeps the bar. The island keeps
    // the bar up while it's open, so its keybind still works over a fullscreen app.
    readonly property bool fullscreen: FullscreenState.trueFullscreen

    visible: !bar.fullscreen || IslandState.open
    anchors {
        top: true
        left: true
        right: true
    }
    // The open window covers the whole screen height, so a click anywhere off a panel
    // lands on the background below and closes it (see the MouseArea below). The input
    // mask keeps clicks to the pills while closed, so windows underneath still get them.
    // The pills are inset from the top so their shadows have room to draw.
    implicitHeight: bar.screen ? bar.screen.height : IslandState.barSpan
    // Reserve only the pill row, so tiled windows stop under the bar and not behind it.
    exclusiveZone: bar.pillHeight + bar.edge
    color: "transparent"

    // Above the outside-click catcher, so the island and its pills get the clicks.
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "a4a-bar"
    // A focus grab (below) routes the keyboard to the bar while a panel is open, so a
    // panel opened from a key (SUPER+A, SUPER+W) takes arrows, Escape and typing with
    // no click first. OnDemand lets the surface hold that focus. Closed: no keyboard.
    WlrLayershell.keyboardFocus: IslandState.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // While a panel is open, grab input for the bar: Hyprland routes the keyboard here
    // (flipping the focus property alone doesn't, once the surface is already up), and a
    // click anywhere outside the bar clears the grab, which closes the panel. This is
    // what dismisses an open panel on an outside click; there's no separate catcher.
    HyprlandFocusGrab {
        id: grab
        windows: [bar]
        active: IslandState.open
        onCleared: IslandState.close()
    }

    // Closed: only the pills take clicks, the rest passes through to the windows
    // below. Open: the whole window takes clicks, so the panel's buttons get them.
    // Clicks outside the panel still reach the outside-click catcher and close it.
    mask: IslandState.open ? openMask : closedMask

    Region {
        id: closedMask
        Region { item: leftPill }
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

    // Background of the open window: a click on empty bar space closes the island.
    // The pills and the panel sit above it and take their own clicks.
    MouseArea {
        anchors.fill: parent
        enabled: IslandState.open
        onClicked: IslandState.close()
    }

    // Keys reach here when nothing inside a page uses them (a text field keeps its
    // own typing, and passes Escape up). The page gets the first go: arrows in the
    // wallpaper grid, letters on a home page.
    FocusScope {
        id: row
        focus: true
        Keys.onPressed: (event) => {
            if (!IslandState.open)
                return
            const panel = IslandState.origin === "status" ? statusPill.body : island.body
            if (panel.handleKey(event)) {
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                IslandState.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Backspace && IslandState.view !== IslandState.home) {
                IslandState.back()
                event.accepted = true
            }
        }
        // A field focused on an earlier page would otherwise keep the keyboard.
        Connections {
            target: IslandState
            function onOpenChanged() { if (IslandState.open) row.forceActiveFocus() }
            function onViewChanged() { row.forceActiveFocus() }
        }
        anchors.fill: parent
        anchors.topMargin: bar.edge
        anchors.leftMargin: bar.edge
        anchors.rightMargin: bar.edge

        BarPill {
            id: leftPill
            anchors.left: parent.left
            anchors.top: parent.top
            height: bar.pillHeight
            // The workspaces' capsule is 24 px in a 38 px pill: 7 px all round.
            width: leftRow.implicitWidth + 7 + (title.visible ? 14 : 7)
            // The title coming and going resizes the pill; ease it like the island.
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            RowLayout {
                id: leftRow
                anchors.left: parent.left
                anchors.leftMargin: 7
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Workspaces {
                    monitor: Hyprland.monitorFor(bar.screen)
                }

                Divider {
                    visible: title.visible
                }

                WindowTitle {
                    id: title
                    visible: IslandState.isShown("title") && text !== ""
                }
            }

            // Scroll anywhere on the pill to move to the next workspace that exists,
            // as SUPER+scroll does (ML4W). It takes no clicks, so the slots still get them.
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

        // The right pill. Its items open their own pages in the control centre, which
        // this pill grows into, anchored at the corner where the click was.
        Morph {
            id: statusPill
            origin: "status"
            anchors.right: parent.right
            anchors.top: parent.top
            pillHeight: bar.pillHeight
            expandedWidth: 420
            // Items are 28 px tall with their own padding: 5 px all round.
            closedWidth: status.implicitWidth + 10
            visible: status.visibleCount > 0 || isOpen

            // Between the items: the control centre's home.
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: IslandState.openTo("control")
            }

            RowLayout {
                id: status
                anchors.centerIn: parent
                spacing: 0

                readonly property var systemKeys: IslandState.shownIn("system")
                readonly property var statusKeys: IslandState.shownIn("status")
                readonly property bool hasTray: tray.visible
                readonly property int visibleCount: (hasTray ? 1 : 0) + systemKeys.length + statusKeys.length

                Tray {
                    id: tray
                    menu: trayMenu
                    barLeft: 0
                    barTop: 0
                }

                Divider {
                    visible: status.hasTray && (status.systemKeys.length + status.statusKeys.length) > 0
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                }

                Repeater {
                    model: status.systemKeys
                    delegate: BarItem {}
                }

                Divider {
                    visible: status.systemKeys.length > 0 && status.statusKeys.length > 0
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                }

                Repeater {
                    model: status.statusKeys
                    delegate: BarItem {}
                }
            }
        }
    }
}
