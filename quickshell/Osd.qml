pragma Singleton

import QtQuick
import Quickshell

// The on-screen indicator's state: which level it shows, and whether it is up. It
// is shown for a moment after a volume or brightness key, then hides itself.
Singleton {
    id: root

    // "volume" or "brightness".
    property string kind: "volume"
    property bool shown: false

    function show(k) {
        kind = k
        if (k === "brightness")
            Brightness.refresh()
        shown = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shown = false
    }
}
