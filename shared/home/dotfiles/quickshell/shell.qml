//@ pragma UseQApplication
//@ pragma IconTheme WhiteSur-light

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    NotificationServer {
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true;
            Notifications.addNotification(notif);
        }
    }

    PanelWindow {
        visible: Notifications.activeNotifications.length > 0
        color: "transparent"
        implicitWidth: 400

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
