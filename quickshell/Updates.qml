pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// How many pacman updates are pending. checkupdates syncs a temporary copy of the
// package database, so it doesn't touch the system's own, and it takes about 15 s.
// So it runs at start and then every 30 minutes, not when the island opens.
Singleton {
    id: root

    property int count: 0
    property bool checking: false
    // checkupdates exits 0 when updates are listed, 2 when none are pending and 1 when
    // it failed (no network, or a stale temporary database). Failed must not look like
    // "up to date".
    property bool failed: false

    function refresh() {
        if (checking)
            return
        checking = true
        checker.running = true
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: checker
        command: ["checkupdates"]
        stdout: StdioCollector {
            id: listed
            onStreamFinished: {
                // One line per package. checkupdates exits non-zero when none are pending,
                // so the count comes from the output, not the exit code.
                root.count = listed.text.split("\n").filter(l => l.trim() !== "").length
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.checking = false
            root.failed = exitCode === 1
            // A run killed part-way leaves a temporary database behind, and every later
            // run then fails. Clear it, so the next check starts clean.
            if (root.failed)
                cleaner.running = true
        }
    }

    Process {
        id: cleaner
        command: ["sh", "-c", "rm -rf \"${TMPDIR:-/tmp}/checkup-db-$(id -u)\""]
    }
}
