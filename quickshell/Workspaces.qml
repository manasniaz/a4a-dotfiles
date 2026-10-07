import QtQuick
import Quickshell.Hyprland

// Workspace slots, from 1 up to the highest in use (at least five), so the row keeps
// its shape as desktops come and go. An empty slot is a faint dot, one with windows a
// solid dot, and the current one an accent capsule with its number in it.
//
// Every slot's place is worked out from the active index, and the slots and the
// capsule all ease to their places on the same curve. So a switch reads as the capsule
// sliding across, not as one slot going dark and another lighting up.
Item {
    id: root

    // The monitor this bar is on; its active workspace is the one marked.
    property var monitor: null

    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 1
    // Named and special workspaces (the scratchpad) have ids below 1 and get no slot.
    readonly property var normal: Hyprland.workspaces.values.filter(w => w.id > 0)
    readonly property int count: Math.max(5, activeId, ...normal.map(w => w.id))
    readonly property int activeIndex: activeId - 1

    readonly property int slotWidth: 20
    readonly property int activeWidth: 32
    readonly property int gap: 2
    readonly property int slotHeight: 24
    // Hovered slot, or -1. Drives the soft pill that follows the pointer.
    property int hoverIndex: -1

    readonly property int motion: 240

    function slotX(i) {
        return i * (slotWidth + gap) + (i > activeIndex ? activeWidth - slotWidth : 0)
    }
    function slotW(i) {
        return i === activeIndex ? activeWidth : slotWidth
    }
    function workspace(id) {
        return normal.find(w => w.id === id) ?? null
    }

    implicitWidth: count * slotWidth + (count - 1) * gap + (activeWidth - slotWidth)
    implicitHeight: slotHeight

    // The pointer's pill, under everything else. Not shown over the current slot,
    // which already stands out.
    Rectangle {
        x: root.hoverIndex >= 0 ? root.slotX(root.hoverIndex) : 0
        width: root.hoverIndex >= 0 ? root.slotW(root.hoverIndex) : 0
        height: root.slotHeight
        radius: height / 2
        color: Theme.fg
        opacity: root.hoverIndex >= 0 && root.hoverIndex !== root.activeIndex ? 0.08 : 0

        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: capsule
        x: root.slotX(root.activeIndex)
        width: root.activeWidth
        height: root.slotHeight
        radius: height / 2
        color: Theme.accent

        Behavior on x { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }
    }

    Repeater {
        model: root.count

        Item {
            id: slot

            required property int index
            readonly property int wsId: index + 1
            readonly property var ws: root.workspace(wsId)
            readonly property bool active: index === root.activeIndex
            readonly property bool occupied: ws !== null && ws.toplevels.values.length > 0
            readonly property bool urgent: ws !== null && ws.urgent

            x: root.slotX(index)
            width: root.slotW(index)
            height: root.slotHeight

            Behavior on x { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: root.motion; easing.type: Easing.OutCubic } }

            // Empty: a small faint dot. Windows: a larger solid one. Urgent: accent.
            Rectangle {
                anchors.centerIn: parent
                readonly property real size: slot.urgent || slot.occupied ? 6 : 4
                width: size
                height: size
                radius: size / 2
                color: slot.urgent ? Theme.accent : (slot.occupied ? Theme.fg : Theme.muted)
                opacity: slot.active ? 0 : (mouse.containsMouse || slot.occupied ? 1 : 0.9)
                scale: mouse.pressed ? 0.8 : 1

                Behavior on opacity { NumberAnimation { duration: 140 } }
                Behavior on scale { NumberAnimation { duration: 100 } }
                Behavior on color { ColorAnimation { duration: 140 } }
            }

            Text {
                anchors.centerIn: parent
                text: slot.wsId
                color: Theme.bg
                font.pixelSize: 12
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
                opacity: slot.active ? 1 : 0

                // Eases in late, so the number appears as the capsule arrives, not ahead of it.
                Behavior on opacity { NumberAnimation { duration: root.motion; easing.type: Easing.InQuart } }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: {
                    if (containsMouse)
                        root.hoverIndex = slot.index
                    else if (root.hoverIndex === slot.index)
                        root.hoverIndex = -1
                }
                // Lua dispatchers, same form as the binds in hypr/binds.lua.
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + slot.wsId + " })")
                // Let the wheel through, so scrolling anywhere on the pill changes desktop.
                onWheel: (wheel) => { wheel.accepted = false }
            }
        }
    }
}
