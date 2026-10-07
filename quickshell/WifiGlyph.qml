import QtQuick

// Wi-Fi as three arcs over a dot, drawn here rather than taken from the icon font:
// the font's signal glyphs are solid wedges that read as a triangle at bar size.
// Arcs beyond the signal level are dimmed, so the strength is readable at a glance.
// Off: every arc dim, with a slash through.
Canvas {
    id: root

    // Signal strength, 0 to 1. 0 with `off` false means on but not joined.
    property real value: 0
    property bool off: false
    property color color: Theme.fg
    property color dimColor: Qt.rgba(color.r, color.g, color.b, 0.3)

    readonly property int lit: off ? 0 : (value >= 0.67 ? 3 : value >= 0.34 ? 2 : value > 0 ? 1 : 0)

    implicitWidth: 18
    implicitHeight: 16

    onLitChanged: requestPaint()
    onColorChanged: requestPaint()
    onOffChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const cx = width / 2
        const cy = height - 2.5
        ctx.lineCap = "round"
        ctx.lineWidth = 1.9

        ctx.fillStyle = lit > 0 ? color : dimColor
        ctx.beginPath()
        ctx.arc(cx, cy, 1.7, 0, 2 * Math.PI)
        ctx.fill()

        for (let i = 1; i <= 3; i++) {
            ctx.strokeStyle = i <= lit ? color : dimColor
            ctx.beginPath()
            ctx.arc(cx, cy, 1.5 + 3.7 * i, -0.75 * Math.PI, -0.25 * Math.PI)
            ctx.stroke()
        }

        if (off) {
            ctx.strokeStyle = color
            ctx.beginPath()
            ctx.moveTo(3, 1.5)
            ctx.lineTo(width - 3, height - 1.5)
            ctx.stroke()
        }
    }
}
