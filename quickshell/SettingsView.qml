import QtQuick
import QtQuick.Layouts

// Settings: what the closed pill shows, and which cards the home view has.
// Each option is a labelled switch, so nothing is hidden behind a chip.
ColumnLayout {
    id: root

    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Tile {
            label: "←"
            implicitWidth: 36
            implicitHeight: 32
            onActivated: IslandState.view = "home"
        }

        Text {
            Layout.fillWidth: true
            text: "Settings"
            color: Theme.fg
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Tile {
            label: "✕"
            implicitWidth: 36
            implicitHeight: 32
            onActivated: IslandState.close()
        }
    }

        ColumnLayout {
            id: content
            width: parent.width
            spacing: 10

            Card {
                title: "Closed pill shows"

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Repeater {
                        model: IslandState.choices

                        OptionRow {
                            required property var modelData
                            label: modelData.label
                            checked: IslandState.isShown(modelData.key)
                            onToggled: IslandState.toggleShown(modelData.key)
                        }
                    }
                }
            }

            NightLightCard {}

            Card {
                title: "Home shows"

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8

                    Repeater {
                        model: IslandState.sections

                        OptionRow {
                            required property var modelData
                            label: modelData.label
                            checked: IslandState.inPanel(modelData.key)
                            onToggled: IslandState.togglePanel(modelData.key)
                        }
                    }
                }
            }
        }
}
