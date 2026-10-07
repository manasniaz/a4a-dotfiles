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
            icon: "back"
            implicitWidth: 36
            implicitHeight: 32
            onActivated: IslandState.back()
        }

        Text {
            Layout.fillWidth: true
            text: "Settings"
            color: Theme.fg
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Tile {
            icon: "close"
            implicitWidth: 36
            implicitHeight: 32
            onActivated: IslandState.close()
        }
    }

        ColumnLayout {
            id: content
            // A layout ignores `width` on its children; this is how it fills.
            Layout.fillWidth: true
            spacing: 10

            Card {
                title: "Bar shows"

                Repeater {
                    model: [
                        { zones: ["left"], label: "Left" },
                        { zones: ["centre"], label: "Island" },
                        { zones: ["system", "status"], label: "Right" }
                    ]

                    ColumnLayout {
                        id: group
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: group.modelData.label
                            color: Theme.fgDim
                            font.pixelSize: 11
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            uniformCellWidths: true
                            columnSpacing: 16
                            rowSpacing: 8

                            Repeater {
                                model: IslandState.choices.filter(c => group.modelData.zones.indexOf(c.zone) !== -1)

                                OptionRow {
                                    required property var modelData
                                    label: modelData.label
                                    checked: IslandState.isShown(modelData.key)
                                    onToggled: IslandState.toggleShown(modelData.key)
                                }
                            }
                        }
                    }
                }
            }

            Card {
                title: "Home pages show"

                Repeater {
                    model: [
                        { panel: "centre", label: "Island" },
                        { panel: "status", label: "Control centre" }
                    ]

                    ColumnLayout {
                        id: homeGroup
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: homeGroup.modelData.label
                            color: Theme.fgDim
                            font.pixelSize: 11
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            uniformCellWidths: true
                            columnSpacing: 16
                            rowSpacing: 8

                            Repeater {
                                model: IslandState.sections.filter(s => s.panel === homeGroup.modelData.panel)

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
        }
}
