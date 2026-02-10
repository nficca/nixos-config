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
        visible: Notifications.visiblePopupNotifications.length > 0
        color: "transparent"
        implicitWidth: 400
        implicitHeight: notificationColumn.implicitHeight

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
            id: notificationColumn
            spacing: 10

            Repeater {
                model: Math.min(5, Notifications.visiblePopupNotifications.length)

                delegate: NotificationPopup {
                    required property int index
                    notification: Notifications.visiblePopupNotifications[index]
                }
            }
        }
    }

    Bar {}
}
