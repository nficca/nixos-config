pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: Colors.background


            // Left
            RowLayout {
                anchors {
                    left: parent.left
                    leftMargin: 5 
                    verticalCenter: parent.verticalCenter
                }

                WorkspacesWidget {}
            }

            // Center
            RowLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                FocusedWindowWidget {}
            }

            // Right
            RowLayout {
                anchors {
                    right: parent.right
                    rightMargin: 5
                    verticalCenter: parent.verticalCenter
                }

                SystemTrayWidget {}
                NotificationWidget {}
                ClockWidget {}
                PowerMenuWidget {}
            }
        }
    }
}
