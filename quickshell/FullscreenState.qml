pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Whether the focused window is truly fullscreen, not maximised (SUPER+M). A window that
// was maximised and then asks for fullscreen (a video in Brave, mpv, VLC) has fullscreen
// 1 and fullscreenClient 2, so either field at 2 counts. Quickshell's copy of the window
// data doesn't refresh when a window changes fullscreen state, so this asks Hyprland
// directly, once per change of
// focus or fullscreen. It's not polled.
Singleton {
    id: root

    property bool trueFullscreen: false

    function refresh() {
        if (!checker.running)
            checker.running = true
    }

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() { root.refresh() }
        function onFocusedWorkspaceChanged() { root.refresh() }
        // An app going fullscreen (a video) doesn't change focus or the workspace's
        // fullscreen flag when the window was already maximised, so the event is the only signal.
        function onRawEvent(event) { if (event.name === "fullscreen") root.refresh() }
    }

    Connections {
        target: Hyprland.focusedWorkspace
        function onHasFullscreenChanged() { root.refresh() }
    }

    Process {
        id: checker
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            id: active
            onStreamFinished: {
                try {
                    const win = JSON.parse(active.text)
                    root.trueFullscreen = win.fullscreen === 2 || win.fullscreenClient === 2
                } catch (e) {
                    root.trueFullscreen = false
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
