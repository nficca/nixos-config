pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    readonly property int historyDuration: 24 * 60 * 60 * 1000

    property bool dndEnabled: false
    property var notifications: []
    property int notificationsVersion: 0

    readonly property var activeNotifications: notifications.filter(n => !n.closed)

    function wrapActions(qmlActions) {
        // QML action objects become invalid after creation,
        // so we must bind their invoke() methods immediately
        const wrapped = [];
        for (let i = 0; i < qmlActions.length; i++) {
            const action = qmlActions[i];
            wrapped.push({
                identifier: action.identifier,
                text: action.text,
                invoke: action.invoke.bind(action)
            });
        }
        return wrapped;
    }

    property var cleanupTimer: Timer {
        interval: 3600000
        running: true
        repeat: true
        onTriggered: {
            const cutoff = Date.now() - root.historyDuration;
            const oldLen = root.notifications.length;
            root.notifications = root.notifications.filter(n => n.timestamp >= cutoff);
            if (root.notifications.length < oldLen) {
                root.notificationsVersion++;
            }
        }
    }

    function addNotification(notification) {
        if (root.dndEnabled && notification.urgency < 2)
            return;
        root.notifications = [root.notifComponent.createObject(root, {
                notification
            }), ...root.notifications].slice(0, 100);

        root.notificationsVersion++;
    }

    function toggleDnd() {
        root.dndEnabled = !root.dndEnabled;
    }

    function clearAll() {
        root.activeNotifications.forEach(n => n.close());
    }

    function clearApp(appName) {
        root.activeNotifications.filter(n => n.appName === appName).forEach(n => n.close());
    }

    component Notif: QtObject {
        id: notif
        required property var notification

        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property int urgency: 0
        property string image: ""
        property bool resident: false
        property int timestamp: Date.now()
        property bool closed: false
        property bool hasAnimated: false
        property var actions: []

        Component.onCompleted: {
            if (!notif.notification)
                return;
            notif.summary = notif.notification.summary;
            notif.body = notif.notification.body;
            notif.appName = notif.notification.appName;
            notif.appIcon = notif.notification.appIcon;
            notif.urgency = notif.notification.urgency;
            notif.image = notif.notification.image;
            notif.resident = notif.notification.resident;

            if (notif.notification.actions?.length > 0) {
                notif.actions = root.wrapActions(notif.notification.actions);
            }
        }

        property Connections conn: Connections {
            target: notif.notification

            function onClosed() {
                notif.closed = true;
            }
            function onSummaryChanged() {
                notif.summary = notif.notification.summary;
            }
            function onBodyChanged() {
                notif.body = notif.notification.body;
            }
            function onAppNameChanged() {
                notif.appName = notif.notification.appName;
            }
            function onAppIconChanged() {
                notif.appIcon = notif.notification.appIcon;
            }
            function onImageChanged() {
                notif.image = notif.notification.image;
            }
            function onUrgencyChanged() {
                notif.urgency = notif.notification.urgency;
            }
            function onActionsChanged() {
                if (notif.notification.actions?.length > 0) {
                    notif.actions = root.wrapActions(notif.notification.actions);
                }
            }
        }

        function close() {
            if (notif.closed)
                return;
            notif.closed = true;
            notif.notification?.dismiss();
            root.notificationsVersion++;
        }

        function invokeAction(actionId) {
            const action = notif.actions.find(a => a.identifier === actionId);
            if (action?.invoke) {
                action.invoke();
                if (!notif.resident)
                    notif.close();
            }
        }
    }

    property Component notifComponent: Component {
        Notif {}
    }
}
