import QtQuick

// Status glyphs from the installed Nerd Font (Material Design icons). A glyph
// is picked from the value it shows, so the Wi-Fi bars and the battery level
// match the real reading:
//   wifi        value is the signal, 0 to 1; `kind` "wifi-off" when the radio is off
//   battery     value is the charge, 0 to 1; a bolt replaces it while `charging`
//   clock, calendar, bluetooth, down, up   fixed glyphs
Text {
    id: root

    property string kind: "wifi"
    property real value: 1
    property bool charging: false
    property bool muted: false

    font.family: "JetBrainsMono Nerd Font Mono"
    font.pixelSize: 15
    color: Theme.fg

    readonly property var codes: ({
        "clock": 0xf0954,
        "brightness": 0xf00e0,
        "power": 0xf0425,
        "camera": 0xf0100,
        "image": 0xf02e9,
        "bell": 0xf009a,
        "calendar": 0xf00ee,
        "bluetooth": 0xf00af,
        "down": 0xf0045,
        "up": 0xf005d,
        "wifi-off": 0xf092d,
        "arch": 0xf303
    })

    text: {
        if (kind === "wifi") {
            const v = Math.max(0, Math.min(1, value))
            const cp = v < 0.25 ? 0xf091f : v < 0.5 ? 0xf0922 : v < 0.75 ? 0xf0925 : 0xf0928
            return String.fromCodePoint(cp)
        }
        if (kind === "battery") {
            if (charging)
                return String.fromCodePoint(0xf0084)
            // battery-10 (0xf007a) up to battery-90 (0xf0082), then battery-full.
            const step = Math.max(1, Math.min(10, Math.round(Math.max(0, Math.min(1, value)) * 10)))
            return String.fromCodePoint(step === 10 ? 0xf0079 : 0xf007a + step - 1)
        }
        if (kind === "volume") {
            if (muted)
                return String.fromCodePoint(0xf075f)
            const v = Math.max(0, Math.min(1, value))
            return String.fromCodePoint(v === 0 ? 0xf075f : v < 0.34 ? 0xf057f : v < 0.67 ? 0xf0580 : 0xf057e)
        }
        const cp = codes[kind]
        return cp === undefined ? "" : String.fromCodePoint(cp)
    }
}
