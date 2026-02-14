pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import ".."

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            // Use Overlay layer so bar receives clicks over the tray menu click catcher
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: implicitHeight

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: Appearance.colors.background

            // Close tray menu when clicking anywhere on bar.
            // TapHandler is used instead of MouseArea to avoid blocking hover events
            // which would prevent child items from changing the cursor shape.
            TapHandler {
                onTapped: {
                    if (TrayMenuState.isVisible) {
                        TrayMenuState.close();
                    }
                }
            }

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
