pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth

// System readings shared by the bar, the island and its cards. CPU, RAM and
// network speed come from /proc, read only while something shows them, so there is
// no daemon and no package. Battery comes from UPower, Wi-Fi and Bluetooth from their services.
Singleton {
    id: root

    property real cpu: 0
    property real ram: 0
    property var prevCpu: null

    // Network speed in bytes per second, summed over every interface but loopback.
    property real downBps: 0
    property real upBps: 0
    // The last 60 readings of download speed, for the network chart.
    property var downHistory: []
    property var prevNet: null
    property real prevNetTime: 0

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryPresent: battery !== null && battery.isLaptopBattery && battery.isPresent
    readonly property bool charging: batteryPresent && battery.state === UPowerDeviceState.Charging

    // Wi-Fi: the radio state, and the network it's joined to (signal is 0 to 1).
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNet: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) ?? null : null
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property int wifiPercent: wifiNet ? Math.round(wifiNet.signalStrength * 100) : 0

    // Bluetooth: whether the adapter is on, and how many devices are connected.
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter !== null && adapter.enabled
    readonly property int btConnected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    function parseCpu(text) {
        // First line: "cpu  user nice system idle iowait irq softirq steal ..."
        const f = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
        const idle = f[3] + f[4]
        // Fields 8 and 9 (guest, guest_nice) are already counted in user and nice.
        const total = f.slice(0, 8).reduce((a, b) => a + b, 0)
        if (prevCpu) {
            const dt = total - prevCpu.total
            const di = idle - prevCpu.idle
            cpu = dt > 0 ? 1 - di / dt : 0
        }
        prevCpu = { idle: idle, total: total }
    }

    function parseMem(text) {
        // MemAvailable, not MemFree: the page cache is reclaimable, so it isn't "used".
        const field = name => Number(text.match(new RegExp(name + ":\\s+(\\d+)"))[1])
        const total = field("MemTotal")
        ram = (total - field("MemAvailable")) / total
    }

    function parseNet(text) {
        let rx = 0
        let tx = 0
        for (const line of text.split("\n").slice(2)) {
            const parts = line.split(":")
            if (parts.length < 2 || parts[0].trim() === "lo")
                continue
            const f = parts[1].trim().split(/\s+/).map(Number)
            rx += f[0]
            tx += f[8]
        }
        const now = Date.now()
        if (prevNet) {
            const dt = (now - prevNetTime) / 1000
            // A counter that goes backwards means an interface came or went; skip it.
            downBps = dt > 0 ? Math.max(0, rx - prevNet.rx) / dt : 0
            upBps = dt > 0 ? Math.max(0, tx - prevNet.tx) / dt : 0
            const h = downHistory.concat([downBps])
            downHistory = h.length > 60 ? h.slice(h.length - 60) : h
        }
        prevNet = { rx: rx, tx: tx }
        prevNetTime = now
    }

    // "1.2 MB/s" for big numbers, "480 KB/s" below a megabyte, like a phone's status bar.
    function fmtRate(bps) {
        if (bps >= 1048576)
            return (bps / 1048576).toFixed(1) + " MB/s"
        return Math.round(bps / 1024) + " KB/s"
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: root.parseCpu(statFile.text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root.parseMem(memFile.text())
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        onLoaded: root.parseNet(netFile.text())
    }

    // Only reads /proc while something on screen shows these numbers: the closed
    // pill's CPU, RAM or speed items, or the open island. Every 2 seconds in the pill,
    // every second while the island is open so its live views move.
    readonly property bool pillUsesStats: IslandState.shown.some(k =>
        k === "cpu" || k === "ram" || k === "download" || k === "upload")

    Timer {
        interval: IslandState.open ? 1000 : 2000
        running: root.pillUsesStats || IslandState.open
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
            netFile.reload()
        }
    }
}
