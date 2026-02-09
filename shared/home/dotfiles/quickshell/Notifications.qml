pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: root

    readonly property int historyDuration: 24 * 60 * 60 * 1000 // 24 hours in milliseconds

    property bool dndEnabled: false
    property var notifications: []
    property int notificationsVersion: 0

    property var activeNotifications: {
        notificationsVersion;
        return notifications.filter(n => !n.closed)
    }

    property var cleanupTimer: Timer {
        interval: 3600000 // 1 hour
        running: true
        repeat: true

        onTriggered: {
            const now = Date.now()
            const oldLength = root.notifications.length

            root.notifications = root.notifications.filter(n => {
                return (now - n.timestamp) < root.historyDuration
            })

            const removed = oldLength - root.notifications.length
            if (removed > 0) {
                console.log(`🗑️  Cleaned up ${removed} old notification(s)`)
                root.notificationsVersion++
            }
        }
    }

    // Add notification from NotificationServer
    function addNotification(notification) {
        // Check DND mode
        if (dndEnabled && notification.urgency < 2) {
            console.log("🔕 DND active - suppressing notification:", notification.summary)
            return
        }

        // Create wrapper
        const notif = notifComponent.createObject(root, {
            notification: notification
        })

        // Add to list (prepend - newest first)
        root.notifications = [notif, ...root.notifications]

        // Enforce cap
        if (root.notifications.length > 100) {
            root.notifications = root.notifications.slice(0, 100)
            console.log("⚠️  Notification cap reached, trimming old entries")
        }

        // Trigger reactive updates
        root.notificationsVersion++

        console.log(`🔔 New notification: ${notification.summary} (urgency: ${notification.urgency})`)
    }

    // Toggle DND mode
    function toggleDnd() {
        dndEnabled = !dndEnabled
        console.log(dndEnabled ? "🔕 DND enabled" : "🔔 DND disabled")
    }

    // Clear all active notifications
    function clearAll() {
        activeNotifications.forEach(n => n.close())
        console.log("🗑️  Cleared all active notifications")
    }

    // Clear all notifications from a specific app
    function clearApp(appName) {
        const cleared = activeNotifications.filter(n => n.appName === appName)
        cleared.forEach(n => n.close())
        console.log(`🗑️  Cleared ${cleared.length} notification(s) from ${appName}`)
    }

    // Notif wrapper component
    property var notifComponent: Component {
        QtObject {
            id: notif

            required property var notification

            // Cached properties
            property string summary: notification.summary
            property string body: notification.body
            property string appName: notification.appName
            property string appIcon: notification.appIcon
            property int urgency: notification.urgency
            property var actions: notification.actions
            property string image: notification.image
            property int timestamp: Date.now()
            property bool closed: false
            property bool hasAnimated: false

            // Close notification
            function close() {
                if (!closed) {
                    closed = true
                    if (notification && typeof notification.close === "function") {
                        notification.close()
                    }
                    root.notificationsVersion++ // Trigger reactive updates
                }
            }

            // Invoke action by ID
            function invokeAction(actionId) {
                const action = actions.find(a => a.identifier === actionId)
                if (action) {
                    action.invoke()
                    console.log(`🔘 Invoked action: ${actionId} for notification: ${summary}`)

                    // Close popup unless notification is resident
                    if (!notification.resident) {
                        close()
                    }
                }
            }

            // Listen for external close events
            property var conn: Connections {
                target: notification

                function onClosed() {
                    notif.closed = true
                }
            }
        }
    }
}
