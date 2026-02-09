import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    spacing: 8

    Repeater {
        model: SystemTray.items

        Item {
            id: trayItem
            required property var modelData

            width: 32
            height: 32

            Image {
                anchors.fill: parent
                source: trayItem.modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.item: trayItem
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
                            menuAnchor.open();
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
