import QtQuick
import Quickshell.Hyprland

// The focused window's title, quiet, beside the workspaces: what has the keyboard,
// without looking for its border. Empty on an empty workspace.
Text {
    id: root

    readonly property var win: Hyprland.activeToplevel
    readonly property var here: Hyprland.focusedWorkspace
    // Hyprland can leave the last window as "active" after a switch to an empty
    // workspace, so the title only counts when the window is on the one in view.
    readonly property bool onScreen: win !== null && win.workspace !== null && here !== null
        && win.workspace.id === here.id

    text: onScreen ? win.title : ""
    visible: text !== ""
    width: Math.min(implicitWidth, 300)
    elide: Text.ElideRight
    color: Theme.fgDim
    font.pixelSize: 12
}
