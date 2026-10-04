import QtQuick
import Quickshell
import Quickshell.Wayland

// A transparent layer under the bar, below the bar's area. While the island is
// open, a click on the windows underneath closes it, and Escape does too.
PanelWindow {
    id: catcher

    visible: IslandState.open
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // Starts below the whole bar window. Overlapping it made the catcher take
    // the clicks meant for the open panel. Clicks on the bar's own background
    // close the island instead (see Bar.qml).
    margins.top: IslandState.barSpan
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    MouseArea {
        anchors.fill: parent
        onClicked: IslandState.close()
    }

    Item {
        anchors.fill: parent
        focus: catcher.visible
        Keys.onEscapePressed: IslandState.close()
    }
}
