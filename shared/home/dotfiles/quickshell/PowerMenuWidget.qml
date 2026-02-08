import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    implicitWidth: 44
    implicitHeight: 24

    property bool menuOpen: false

    readonly property int buttonHeight: 36
    readonly property int buttonRadius: 8
    readonly property int buttonFontSize: 14
    readonly property int animationDuration: 150
    readonly property int menuPadding: 10
    readonly property int menuSpacing: 8
    readonly property int menuWidth: 200

    Process {
        id: lockProcess
        command: ["hyprlock"]
    }

    Process {
        id: logoutProcess
        command: ["niri", "msg", "action", "quit"]
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Rectangle {
        width: 26
        height: 26
        anchors.centerIn: parent
        color: Colors.active
        radius: 13
        scale: mouseArea.pressed ? 0.9 : (mouseArea.containsMouse ? 1.1 : 1.0)

        Text {
            anchors.centerIn: parent
            text: "⏻"
            font.pixelSize: 16
            color: Colors.background
        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
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
            color: Colors.background
            border.color: Colors.inactive
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
                    color: mouseArea.containsMouse ? (isCancel ? Colors.inactive : Colors.active) : (isCancel ? "transparent" : Colors.backgroundAlt)
                    border.color: isCancel ? Colors.inactive : "transparent"
                    border.width: isCancel ? 1 : 0
                    radius: root.buttonRadius

                    Text {
                        anchors.centerIn: parent
                        text: label
                        font.pixelSize: root.buttonFontSize
                        color: mouseArea.containsMouse && !isCancel ? Colors.background : Colors.foreground
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.menuOpen = false;
                            if (processId === "lock") lockProcess.running = true;
                            else if (processId === "logout") logoutProcess.running = true;
                            else if (processId === "suspend") suspendProcess.running = true;
                            else if (processId === "reboot") rebootProcess.running = true;
                            else if (processId === "shutdown") shutdownProcess.running = true;
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
