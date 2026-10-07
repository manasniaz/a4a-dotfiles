import QtQuick

// The page inside an open panel, scrolling when it's taller than the screen allows.
// Home pages draw their own header; the others start with a DetailHeader.
Flickable {
    id: root

    // "centre" or "status": which panel this is.
    required property string origin
    // Load the page only while the panel is open or animating, so each page reads
    // its state fresh when it opens and nothing runs behind a closed pill.
    property bool live: false

    // The page this panel shows. It only follows IslandState.view for pages that live
    // here, so a panel that's closing (because a page in the other panel was opened)
    // fades out with its own content.
    property string page: origin === "status" ? "control" : "home"

    function follow() {
        const v = IslandState.view
        const o = IslandState.owner(v)
        if (o === origin || (o === "" && IslandState.origin === origin))
            page = v
    }
    Connections {
        target: IslandState
        function onViewChanged() { root.follow() }
        function onOriginChanged() { root.follow() }
    }
    Component.onCompleted: follow()

    // The page's own key handling (arrows in the wallpaper grid, letters on a home
    // page). Returns true when it used the key.
    function handleKey(event) {
        const item = body.item
        return item !== null && typeof item.handleKey === "function" && item.handleKey(event)
    }

    // Tallest the panel gets, so a very long list scrolls instead of running off screen.
    readonly property int maxHeight: 1000

    implicitHeight: Math.min(body.height, maxHeight)
    contentHeight: body.height
    contentWidth: width
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    Loader {
        id: body
        width: root.width
        height: item ? item.implicitHeight : 0
        active: root.live
        sourceComponent: ({
            home: homeView,
            control: controlView,
            wifi: wifiView,
            bluetooth: bluetoothView,
            pairing: pairingView,
            calendar: calendarView,
            clock: clockView,
            media: mediaView,
            network: networkView,
            sound: soundView,
            system: systemView,
            settings: settingsView,
            wallpaper: wallpaperView,
            power: powerView,
            capture: captureView,
            notifications: notificationsView
        })[root.page] ?? (root.origin === "status" ? controlView : homeView)
    }

    Component { id: homeView; HomeView {} }
    Component { id: controlView; ControlView {} }
    Component { id: wifiView; WifiView {} }
    Component { id: bluetoothView; BluetoothView {} }
    Component { id: pairingView; PairingView {} }
    Component { id: settingsView; SettingsView {} }
    Component { id: calendarView; CalendarView {} }
    Component { id: systemView; SystemView {} }
    Component { id: clockView; ClockView {} }
    Component { id: mediaView; MediaView {} }
    Component { id: networkView; NetworkView {} }
    Component { id: soundView; SoundView {} }
    Component { id: wallpaperView; WallpaperView {} }
    Component { id: powerView; PowerView {} }
    Component { id: captureView; CaptureView {} }
    Component { id: notificationsView; NotificationsView {} }
}
