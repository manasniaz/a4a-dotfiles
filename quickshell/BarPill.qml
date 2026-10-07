import QtQuick
import QtQuick.Effects

// The surface every bar group sits on: an opaque rounded pill with a hairline edge
// and a soft shadow under it, so it stays readable on bright wallpapers. The shadow
// is drawn from its own copy of the shape, so the pill's text is never put through
// the effect (that would soften it).
Item {
    id: root

    default property alias content: body.data
    property real radius: height / 2
    // Lets the island fade its shadow in as it opens.
    property real shadowStrength: 1
    // The pill itself, for callers that need to clip to it.
    readonly property alias surface: body

    Rectangle {
        id: shape
        anchors.fill: parent
        radius: root.radius
        color: Theme.pill
        visible: false
    }

    MultiEffect {
        source: shape
        anchors.fill: shape
        shadowEnabled: true
        shadowColor: "black"
        shadowOpacity: 0.32 * root.shadowStrength
        shadowBlur: 0.55
        blurMax: 20
        shadowVerticalOffset: 2
    }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: root.radius
        color: Theme.pill
        border.width: 1
        border.color: Theme.line
    }
}
