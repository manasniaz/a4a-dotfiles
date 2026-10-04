import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// The power menu, behind the power icon in the island header. Lock runs at once,
// since you unlock it again. The rest need a second click, so a stray click can't
// log you out or switch the machine off.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "Power"
        backTo: "home"
    }

    // The active mode, read when the page opens. powerprofilesctl talks to
    // power-profiles-daemon, which handles the CPU and platform settings.
    property string profile: ""

    Process {
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: StdioCollector {
            id: current
            onStreamFinished: root.profile = current.text.trim()
        }
    }

    function setProfile(name) {
        Quickshell.execDetached(["powerprofilesctl", "set", name])
        profile = name
    }

    Card {
        title: "Mode"

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Saver"
                armed: root.profile === "power-saver"
                onActivated: root.setProfile("power-saver")
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Balanced"
                armed: root.profile === "balanced"
                onActivated: root.setProfile("balanced")
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Performance"
                armed: root.profile === "performance"
                onActivated: root.setProfile("performance")
            }
        }
    }

    Card {
        title: "Session"

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: "Lock"
                onActivated: IslandState.run(["hyprlock", "-c", Quickshell.env("HOME") + "/.config/hyprlock/hyprlock.conf"])
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: IslandState.armed === "logout" ? "Confirm" : "Log out"
                armed: IslandState.armed === "logout"
                onActivated: root.confirm("logout", ["hyprctl", "dispatch", "hl.dsp.exit()"])
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: IslandState.armed === "reboot" ? "Confirm" : "Restart"
                armed: IslandState.armed === "reboot"
                onActivated: root.confirm("reboot", ["systemctl", "reboot"])
            }
            Tile {
                Layout.fillWidth: true
                implicitHeight: 34
                label: IslandState.armed === "poweroff" ? "Confirm" : "Shut down"
                armed: IslandState.armed === "poweroff"
                onActivated: root.confirm("poweroff", ["systemctl", "poweroff"])
            }
        }
    }

    // First click arms a power action, the second runs it.
    function confirm(name, cmd) {
        if (IslandState.armed === name)
            IslandState.run(cmd)
        else
            IslandState.armed = name
    }
}
