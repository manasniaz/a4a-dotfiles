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

    // The bar's panels, for keybinds and scripts.
    IpcHandler {
        target: "island"

        // The island's home, or close: quickshell ipc call island toggle
        function toggle(): void {
            IslandState.toggle()
        }

        // Open one page, in the panel it belongs to: quickshell ipc call island view wifi
        function view(name: string): void {
            IslandState.openTo(name)
        }

        // A page's key: opens it, or closes it if it's already showing
        // (see IslandState.toggleTo): quickshell ipc call island go control
        function go(name: string): void {
            IslandState.toggleTo(name)
        }
    }

    // Bluetooth pairing requests from scripts/a4a-bt-agent (see Pairing.qml).
    IpcHandler {
        target: "pairing"

        function request(id: int, kind: string, device: string, code: string): void {
            Pairing.receive(id, kind, device, code)
        }

        function entered(id: int, count: int): void {
            Pairing.progress(id, count)
        }

        function cancel(id: int): void {
            Pairing.cancel(id)
        }
    }
}
