pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import ".."

Item {
    id: popup

    property var notification: null
    property bool isHovered: false
    property int elapsed: 0
    property bool explicitDismiss: false

    readonly property var timeouts: [-1, 10000, -1, 5000]
    readonly property int timeout: notification ? timeouts[notification.urgency] || 10000 : 0

    readonly property color borderColor: !notification ? Colors.border : notification.urgency === 2 ? Colors.urgent : Colors.border
    readonly property color progressColor: !notification ? Colors.active : notification.urgency === 2 ? Colors.urgent : notification.urgency === 0 ? Colors.low : Colors.active

    readonly property string normalizedAppIcon: normalizePath(notification?.appIcon ?? "")
    readonly property string normalizedImage: normalizePath(notification?.image ?? "")
    readonly property bool imagesMatch: normalizedAppIcon !== "" && normalizedImage !== "" && normalizedAppIcon === normalizedImage

    // The icon is high-priority. Try the content image if there's no icon.
    readonly property string iconSource: {
        const icon = normalizedAppIcon || normalizedImage;
        if (!icon)
            return "";
        return Quickshell.iconPath(icon);
    }

    // Don't show content image when:
    // - The icon is missing since we'll use the image as the icon
    // - The icon and the image are the same since we don't want to repeat it
    readonly property string imageSource: !notification?.appIcon || imagesMatch ? "" : notification?.image

    function normalizePath(value) {
        if (value.startsWith("image://icon/"))
            return value.substring(13);
        if (value.startsWith("file://"))
            return value.substring(7);
        return value;
    }

    function dismiss(isExplicit) {
        popup.explicitDismiss = isExplicit;
        exitAnimation.start();
    }

    implicitWidth: 400
    implicitHeight: notification?.closed ? 0 : container.height
    visible: notification && notification.popupVisible && !notification.closed

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Component.onCompleted: {
        if (popup.notification) {
            popup.notification.hasAnimated = true;
            entryAnimation.start();
        }
    }

    SequentialAnimation {
        id: entryAnimation
        ParallelAnimation {
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
    }

    SequentialAnimation {
        id: exitAnimation
        ParallelAnimation {
            PropertyAnimation {
                target: container
                property: "opacity"
                to: 0
                duration: 120
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: container
                property: "scale"
                to: 0.8
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
        ScriptAction {
            script: {
                if (popup.notification) {
                    if (popup.explicitDismiss) {
                        popup.notification.close();
                    } else {
                        popup.notification.hidePopup();
                    }
                }
            }
        }
    }

    Timer {
        interval: 100
        running: popup.timeout > 0 && !popup.isHovered && popup.visible
        repeat: true
        onTriggered: {
            popup.elapsed += interval;
            if (popup.elapsed >= popup.timeout)
                popup.dismiss(false);
        }
    }

    Item {
        id: container
        width: parent.width
        height: contentColumn.height + 24
        opacity: 0
        scale: 0.9

        Rectangle {
            id: background
            anchors.fill: parent
            color: Colors.background
            radius: 8
            border.width: 1
            border.color: popup.borderColor

            Rectangle {
                visible: popup.timeout > 0
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
                    width: popup.timeout > 0 ? parent.width * (1 - popup.elapsed / popup.timeout) : 0
                    radius: 2
                    color: popup.progressColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.Linear
                        }
                    }
                }
            }

            Column {
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 12
                    rightMargin: 32
                }
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 12

                    Image {
                        id: appIcon
                        visible: source !== ""
                        source: popup.iconSource
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                visible = false;
                            }
                        }
                    }

                    Column {
                        width: parent.width - (appIcon.visible ? appIcon.width + parent.spacing : 0)
                        spacing: 4

                        Text {
                            width: parent.width
                            text: popup.notification?.summary ?? ""
                            color: Colors.text
                            font.pixelSize: 14
                            font.bold: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: popup.notification?.body ?? ""
                            color: Colors.textSecondary
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            textFormat: Text.RichText
                            visible: text !== ""
                        }
                    }
                }

                Image {
                    visible: source !== ""
                    source: popup.imageSource
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                    height: Math.min(sourceSize.height, 200)
                    asynchronous: true
                }

                Row {
                    visible: popup.notification?.actions?.length > 0
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: popup.notification?.actions ?? []

                        delegate: Rectangle {
                            id: actionDelegate
                            required property var modelData

                            width: 80
                            height: 28
                            radius: 6
                            color: mouseArea.pressed ? Colors.active : mouseArea.containsMouse ? Colors.backgroundAlt : Colors.background
                            border.width: 1
                            border.color: Colors.border

                            Text {
                                anchors.centerIn: parent
                                text: actionDelegate.modelData?.text ?? "Action"
                                color: Colors.text
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (actionDelegate.modelData?.identifier) {
                                        popup.notification.invokeAction(actionDelegate.modelData.identifier);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 8
                }
                width: 20
                height: 20
                radius: 10
                color: closeArea.pressed ? Colors.active : closeArea.containsMouse ? Colors.backgroundAlt : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Colors.text
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.dismiss(true)
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.RightButton

                onEntered: {
                    popup.isHovered = true;
                    background.border.color = Colors.active;
                }

                onExited: {
                    popup.isHovered = false;
                    background.border.color = popup.borderColor;
                }

                onClicked: popup.dismiss(true)
            }
        }
    }
}
