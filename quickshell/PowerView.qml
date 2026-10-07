import QtQuick
import QtQuick.Layouts
import Quickshell

// The power menu, in the control centre (its power button, P, or SUPER+X). Lock runs
// at once, since you unlock it again. The rest need a second click, so a stray click
// can't log you out or switch the machine off. The power mode is on the control
// centre's front page.
ColumnLayout {
    id: root

    spacing: 10

    DetailHeader {
        title: "Power"
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
                onActivated: IslandState.run([Quickshell.env("HOME") + "/.local/bin/a4a-lock"])
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
