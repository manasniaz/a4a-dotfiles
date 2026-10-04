// A4A shell entry point. One bar and one outside-click catcher per monitor.
// Quickshell is the framework only: every widget here is written from scratch
// (see SKILLS.md).

import Quickshell
import Quickshell.Io

Scope {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        OutsideClick {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        OsdWindow {
            required property var modelData
            screen: modelData
        }
    }

    // The key binds show the volume or brightness indicator: quickshell ipc call osd flash volume
    IpcHandler {
        target: "osd"

        function flash(kind: string): void {
            Osd.show(kind)
        }
    }

    // Lets a keybind open the island: quickshell ipc call island toggle
    IpcHandler {
        target: "island"

        function toggle(): void {
            IslandState.toggle()
        }

        // Opens the island on one screen: quickshell ipc call island view calendar
        function view(name: string): void {
            IslandState.openTo(name)
        }
    }
}
