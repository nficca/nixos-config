import QtQuick

Item {
    id: root

    implicitWidth: 44
    implicitHeight: 24

    property int activeCount: Notifications.activeNotifications.length

    Rectangle {
        id: button
        width: 30
        height: 30
        radius: 15
        anchors.centerIn: parent

        color: mouseArea.pressed ? Colors.active : mouseArea.containsMouse ? Colors.backgroundAlt : Notifications.dndEnabled ? Colors.inactive : Colors.background

        border.width: 1
        border.color: Notifications.dndEnabled ? Colors.inactive : Colors.border

        scale: mouseArea.pressed ? 0.95 : mouseArea.containsMouse ? 1.05 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        // Bell icon
        Text {
            anchors.centerIn: parent
            text: Notifications.dndEnabled ? "🔕" : "🔔"
            font.pixelSize: 16
        }

        // Count badge
        Rectangle {
            visible: root.activeCount > 0
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: -4
                topMargin: -4
            }
            width: 16
            height: 16
            radius: 8
            color: Colors.urgent
            border.width: 2
            border.color: Colors.background

            Text {
                anchors.centerIn: parent
                text: root.activeCount > 9 ? "9+" : root.activeCount.toString()
                color: Colors.text
                font.pixelSize: 9
                font.bold: true
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Notifications.toggleDnd();
            }
        }

        PopupTip {
            anchors.fill: parent
            text: root.activeCount > 0 ? root.activeCount + " notification" + (root.activeCount > 1 ? "s" : "") : "No notifications"
            active: mouseArea.containsMouse
            offsetY: height + 10
        }
    }
}
