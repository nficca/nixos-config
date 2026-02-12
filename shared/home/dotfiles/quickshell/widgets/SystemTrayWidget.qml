import QtQuick
import Quickshell.Services.SystemTray
import ".."

Row {
    id: root
    spacing: 8

    // Single shared menu for all tray items
    TrayMenu {
        id: trayMenu
    }

    Repeater {
        model: SystemTray.items

        Item {
            id: trayItem
            required property var modelData

            width: 24
            height: 24

            Image {
                anchors.fill: parent

                // Request a higher resolution icon from the source
                // so there's more detail when scaling down to display size.
                sourceSize: Qt.size(48, 48)
                source: trayItem.modelData.icon

                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu) {
                            TrayMenuState.open(trayItem.modelData.menu, trayItem);
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayItem.modelData.secondaryActivate();
                    }
                }

                onWheel: wheel => {
                    trayItem.modelData.scroll(wheel.angleDelta.y, false);
                }
            }
        }
    }
}
