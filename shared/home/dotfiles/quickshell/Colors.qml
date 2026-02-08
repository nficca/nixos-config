pragma Singleton
import QtQuick

QtObject {
    property SystemPalette system: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    readonly property color background: "#2e3440"
    readonly property color foreground: "#d8dee9"
    readonly property color active: "#88c0d0"
    readonly property color inactive: "#4c566a"
}
