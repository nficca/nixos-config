//@ pragma UseQApplication
//@ pragma IconTheme WhiteSur-light

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

pragma ComponentBehavior: Bound

Scope {
    NotificationServer {
        id: notificationServer

        onNotification: notif => {
            Notifications.addNotification(notif)
        }
    }

    // Notification popups container
    PanelWindow {
        visible: Notifications.activeNotifications.length > 0
        color: "transparent"

        screen: Quickshell.screens[0]
        anchors {
            right: true
            top: true
        }

        margins {
            right: 10
            top: 10
        }

        Column {
            spacing: 10

            Repeater {
                id: notificationRepeater
                model: Math.min(5, Notifications.activeNotifications.length)

                delegate: NotificationPopup {
                    required property int index
                    notification: Notifications.activeNotifications[index]
                }
            }
        }
    }

    Bar {}
}
