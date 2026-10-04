pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// The default output and its volume, from PipeWire. The tracker keeps the sinks'
// audio values live, so the slider and the pill follow the hardware.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasSink: sink !== null && sink.audio !== null
    readonly property real volume: hasSink ? sink.audio.volume : 0
    readonly property bool muted: hasSink ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    // Every output, laptop speakers, HDMI and Bluetooth alike.
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)

    PwObjectTracker {
        objects: root.sinks.concat(root.sink ? [root.sink] : [])
    }

    function setVolume(v) {
        if (hasSink)
            sink.audio.volume = Math.max(0, Math.min(1, v))
    }

    function toggleMute() {
        if (hasSink)
            sink.audio.muted = !sink.audio.muted
    }

    // Make an output the default, so everything plays through it from now on.
    function makeDefault(node) {
        Quickshell.execDetached(["wpctl", "set-default", String(node.id)])
    }

    function label(node) {
        return node.nickname || node.description || node.name
    }
}
