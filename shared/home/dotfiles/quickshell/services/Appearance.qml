pragma Singleton
import QtQuick

QtObject {
    readonly property QtObject anim: QtObject {
        // Durations
        readonly property int fast: 80
        readonly property int normal: 120
        readonly property int smooth: 180
        readonly property int hover: 50

        // Easing curves
        readonly property QtObject curves: QtObject {
            readonly property list<real> standard: [0.2, 0.0, 0, 1.0]
            readonly property list<real> decelerate: [0.05, 0.7, 0.1, 1.0]
            readonly property list<real> accelerate: [0.3, 0.0, 0.8, 0.15]
            readonly property list<real> spring: [0.34, 1.56, 0.64, 1.0]
        }
    }

    readonly property QtObject colors: QtObject {
        readonly property color background: "#eceff4"
        readonly property color backgroundAlt: "#e5e9f0"
        readonly property color foreground: "#2e3440"
        readonly property color active: "#5e81ac"
        readonly property color inactive: "#d8dee9"
        readonly property color text: "#2e3440"
        readonly property color textSecondary: "#4c566a"
        readonly property color border: "#d8dee9"
        readonly property color urgent: "#bf616a"
        readonly property color low: "#a3be8c"
    }
}
