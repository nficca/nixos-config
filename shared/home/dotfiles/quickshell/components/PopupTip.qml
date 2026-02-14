import QtQuick
import Quickshell
import ".."

Item {
    id: root

    required property string text

    property bool active: false
    property bool hidden: true
    property int delay: 500
    property real offsetX: 0
    property real offsetY: root.height + 5


    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root.hidden = false
    }

    onActiveChanged: {
        if (active) {
            showTimer.start()
        } else {
            showTimer.stop()
            hidden = true
        }
    }

    PopupWindow {
        id: popup
        visible: !root.hidden
        anchor.window: root.QsWindow.window
        anchor.rect.x: root.mapToItem(null, 0, 0).x + root.width / 2 - width / 2 + root.offsetX
        anchor.rect.y: root.mapToItem(null, 0, 0).y + root.offsetY
        implicitWidth: content.width
        implicitHeight: content.height
        color: "transparent"

        Rectangle {
            id: content
            width: label.implicitWidth + 16
            height: label.implicitHeight + 8
            color: Appearance.colors.backgroundAlt
            border.color: Appearance.colors.border
            border.width: 1
            radius: 4

            Text {
                id: label
                anchors.centerIn: parent
                text: root.text
                color: Appearance.colors.text
                font.pixelSize: 12
            }
        }
    }
}
