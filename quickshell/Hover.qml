import QtQuick

// The tint every clickable thing on the bar uses: faint on hover, stronger while
// pressed. One look for all of them, so the bar reads as one piece. The parent
// passes in its own hover and press state.
Rectangle {
    property bool hovered: false
    property bool pressed: false

    anchors.fill: parent
    radius: height / 2
    color: Theme.fg
    opacity: pressed ? 0.14 : (hovered ? 0.08 : 0)

    Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }
}
