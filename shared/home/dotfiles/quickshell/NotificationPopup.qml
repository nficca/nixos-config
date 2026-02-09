import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: popup

    property var notification: null

    property bool isHovered: false
    property real dragX: 0
    property bool isDragging: false
    property int timeout: notification ? getTimeout() : 0
    property int elapsed: 0

    width: 400
    height: (notification && notification.closed) ? 0 : (notification ? container.height : 0)
    visible: notification !== null && !notification.closed
    enabled: notification !== null

    Behavior on height {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    function getTimeout() {
        if (!notification) return 0
        if (notification.urgency === 2) return -1 // Critical
        if (notification.urgency === 0) return 5000 // Low
        return 10000 // Normal
    }

    function getBorderColor() {
        if (!notification) return Colors.border
        return (notification.urgency === 2) ? Colors.urgent : Colors.border
    }

    function getProgressColor() {
        if (!notification) return Colors.active
        if (notification.urgency === 2) return Colors.urgent
        if (notification.urgency === 0) return Colors.low
        return Colors.active
    }

    function dismiss() {
        exitAnimation.start()
    }

    // Entry animation
    Component.onCompleted: {
        if (notification) {
            notification.hasAnimated = true
            entryAnimation.start()
        }
    }

    property var entryAnimation: SequentialAnimation {
        PropertyAnimation {
            target: container
            property: "x"
            from: 80
            to: 0
            duration: 180
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: container
            property: "opacity"
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: container
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 180
            easing.type: Easing.OutQuad
        }
    }

    property var exitAnimation: ParallelAnimation {
        PropertyAnimation {
            target: container
            property: "opacity"
            from: 1
            to: 0
            duration: 120
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: container
            property: "scale"
            from: 1.0
            to: 0.8
            duration: 120
            easing.type: Easing.OutQuad
        }
        onFinished: {
            notification.close()
        }
    }

    property var snapBackAnimation: PropertyAnimation {
        target: container
        property: "x"
        to: 0
        duration: 150
        easing.type: Easing.OutQuad
    }

    // Auto-dismiss timer
    property var dismissTimer: Timer {
        interval: 100
        running: timeout > 0 && !isHovered && !isDragging && visible
        repeat: true

        onTriggered: {
            elapsed += interval
            if (elapsed >= timeout) {
                dismiss()
            }
        }
    }

    Item {
        id: container
        width: 400
        height: contentColumn.height + 24
        opacity: 0
        scale: 0.9
        x: 0

        Rectangle {
            id: background
            anchors.fill: parent
            color: Colors.background
            radius: 8
            border.width: 1
            border.color: getBorderColor()

            // Progress bar at bottom
            Rectangle {
                visible: timeout > 0
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 1
                }
                height: 3
                radius: 2
                color: Colors.backgroundAlt

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: timeout > 0 ? parent.width * (1 - elapsed / timeout) : 0
                    radius: 2
                    color: getProgressColor()
                }
            }

            Column {
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                }
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 12

                    // App icon
                    Image {
                        id: appIcon
                        visible: notification.appIcon !== ""
                        source: notification.appIcon
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                    }

                    Column {
                        width: parent.width - appIcon.width - parent.spacing - closeButton.width - 12
                        spacing: 4

                        // Summary (title)
                        Text {
                            width: parent.width
                            text: notification.summary
                            color: Colors.text
                            font.pixelSize: 14
                            font.bold: true
                            wrapMode: Text.Wrap
                        }

                        // Body text
                        Text {
                            width: parent.width
                            text: notification.body
                            color: Colors.textSecondary
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            textFormat: Text.RichText
                            visible: notification.body !== ""
                        }
                    }

                    // Close button
                    Rectangle {
                        id: closeButton
                        width: 20
                        height: 20
                        radius: 10
                        color: closeMouseArea.pressed ? Colors.active :
                               closeMouseArea.containsMouse ? Colors.backgroundAlt :
                               "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: Colors.text
                            font.pixelSize: 16
                            font.bold: true
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dismiss()
                        }
                    }
                }

                // Notification image
                Image {
                    visible: notification.image !== ""
                    source: notification.image
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                    height: Math.min(sourceSize.height, 200)
                }

                // Action buttons
                Row {
                    visible: notification.actions && notification.actions.length > 0
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: notification.actions || []

                        Rectangle {
                            width: 80
                            height: 28
                            radius: 6
                            color: actionMouseArea.pressed ? Colors.active :
                                   actionMouseArea.containsMouse ? Colors.backgroundAlt :
                                   Colors.background
                            border.width: 1
                            border.color: Colors.border

                            Text {
                                anchors.centerIn: parent
                                text: modelData.text
                                color: Colors.text
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: actionMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    notification.invokeAction(modelData.identifier)
                                }
                            }
                        }
                    }
                }
            }

            // Main click area
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                drag.target: container
                drag.axis: Drag.XAxis
                drag.minimumX: -container.width
                drag.maximumX: container.width

                onEntered: {
                    isHovered = true
                    background.border.color = Colors.active
                }

                onExited: {
                    if (!isDragging) {
                        isHovered = false
                        background.border.color = getBorderColor()
                    }
                }

                onClicked: {
                    if (!isDragging) {
                        dismiss()
                    }
                }

                onPressed: {
                    isDragging = false
                    dragX = container.x
                }

                onPositionChanged: {
                    if (Math.abs(container.x) > 10) {
                        isDragging = true
                    }
                    dragX = container.x
                }

                onReleased: {
                    // Swipe to dismiss threshold: 35% of width
                    if (Math.abs(dragX) > container.width * 0.35) {
                        dismiss()
                    } else {
                        // Snap back
                        snapBackAnimation.start()
                    }

                    isDragging = false
                    if (!containsMouse) {
                        isHovered = false
                        background.border.color = getBorderColor()
                    }
                }
            }
        }
    }
}
