import QtQuick
import Quickshell
import ".."

Item {
    id: root
    implicitWidth: 44
    implicitHeight: 24

    property bool menuOpen: false

    readonly property int buttonHeight: 36
    readonly property int buttonRadius: 8
    readonly property int buttonFontSize: 14
    readonly property int animationDuration: Appearance.anim.smooth
    readonly property int menuPadding: 10
    readonly property int menuSpacing: 8
    readonly property int menuWidth: 200

    Rectangle {
        width: 30
        height: 30
        anchors.centerIn: parent
        color: Appearance.colors.active
        radius: 15
        scale: mouseArea.pressed ? 0.9 : (mouseArea.containsMouse ? 1.1 : 1.0)

        Text {
            anchors.centerIn: parent
            text: "⏻"
            font.pixelSize: 18
            color: Appearance.colors.background
        }

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.fast
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.menuOpen = !root.menuOpen
    }

    FloatingWindow {
        id: popup
        title: "quickshell-power-menu"
        visible: root.menuOpen
        color: "transparent"
        implicitWidth: root.menuWidth
        implicitHeight: contentColumn.implicitHeight + (root.menuPadding * 2)

        Rectangle {
            anchors.fill: parent
            color: Appearance.colors.background
            border.color: Appearance.colors.inactive
            border.width: 1
            radius: root.buttonRadius
        }

        Column {
            id: contentColumn
            anchors.centerIn: parent
            anchors.margins: root.menuPadding
            spacing: root.menuSpacing
            width: parent.width - (root.menuPadding * 2)

            Repeater {
                model: ListModel {
                    ListElement { label: "Lock"; processId: "lock"; isCancel: false }
                    ListElement { label: "Logout"; processId: "logout"; isCancel: false }
                    ListElement { label: "Suspend"; processId: "suspend"; isCancel: false }
                    ListElement { label: "Reboot"; processId: "reboot"; isCancel: false }
                    ListElement { label: "Shutdown"; processId: "shutdown"; isCancel: false }
                    ListElement { label: "Cancel"; processId: ""; isCancel: true }
                }

                delegate: Rectangle {
                    required property string label
                    required property string processId
                    required property bool isCancel

                    width: contentColumn.width
                    height: root.buttonHeight
                    color: mouseArea.containsMouse ? (isCancel ? Appearance.colors.inactive : Appearance.colors.active) : (isCancel ? "transparent" : Appearance.colors.backgroundAlt)
                    border.color: isCancel ? Appearance.colors.inactive : "transparent"
                    border.width: isCancel ? 1 : 0
                    radius: root.buttonRadius

                    Text {
                        anchors.centerIn: parent
                        text: label
                        font.pixelSize: root.buttonFontSize
                        color: mouseArea.containsMouse && !isCancel ? Appearance.colors.background : Appearance.colors.foreground
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.menuOpen = false;
                            if (processId === "lock") SystemActions.lock();
                            else if (processId === "logout") SystemActions.logout();
                            else if (processId === "suspend") SystemActions.suspend();
                            else if (processId === "reboot") SystemActions.reboot();
                            else if (processId === "shutdown") SystemActions.shutdown();
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: root.animationDuration }
                    }
                }
            }
        }
    }
}
