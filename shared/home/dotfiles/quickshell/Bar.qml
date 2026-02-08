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

            implicitHeight: 30


            // Left
            RowLayout {
                anchors {
                    left: parent.left
                    leftMargin: 25
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

                ClockWidget {}
            }

            // Right
            RowLayout {
                anchors {
                    right: parent.right
                    rightMargin: 25
                    verticalCenter: parent.verticalCenter
                }

                SystemTrayWidget {}
            }
        }
    }
}
