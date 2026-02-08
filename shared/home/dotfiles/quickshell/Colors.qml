pragma Singleton
import QtQuick

QtObject {
    property SystemPalette system: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    readonly property color background: "#eceff4"
    readonly property color backgroundAlt: "#e5e9f0"
    readonly property color foreground: "#2e3440"
    readonly property color active: "#5e81ac"
    readonly property color inactive: "#d8dee9"
}
