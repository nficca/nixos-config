import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import ".."

Item {
    id: root

    readonly property int menuWidth: 220
    readonly property int menuPadding: 6
    readonly property int itemHeight: 28
    readonly property int itemPadding: 8
    readonly property int iconSize: 16
    readonly property int fontSize: 13
    readonly property int borderRadius: 6
    readonly property int animationDuration: 100

    Connections {
        target: TrayMenuState
        function onOpenRequested(handle, anchor) {
            menuStack.clear()
            menuStack.push(menuLevelComponent.createObject(menuStack, { menuHandle: handle }))
        }
    }

    // Click-outside catcher - catches clicks outside the bar to close menu
    PanelWindow {
        id: clickCatcher
        visible: TrayMenuState.menuOpen
        color: "transparent"

        // Top layer is below bar (Overlay) so bar receives clicks in its area
        WlrLayershell.layer: WlrLayer.Top

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: TrayMenuState.close()
        }
    }

    // Menu popup
    PopupWindow {
        id: menuPopup
        visible: TrayMenuState.menuOpen && TrayMenuState.anchorItem
        anchor.window: TrayMenuState.anchorItem ? TrayMenuState.anchorItem.QsWindow.window : null
        anchor.rect.x: TrayMenuState.anchorItem ? TrayMenuState.anchorItem.mapToItem(null, 0, 0).x + TrayMenuState.anchorItem.width / 2 - width / 2 : 0
        anchor.rect.y: TrayMenuState.anchorItem ? TrayMenuState.anchorItem.mapToItem(null, 0, 0).y + TrayMenuState.anchorItem.height + 5 : 0
        color: "transparent"

        implicitWidth: menuContent.width
        implicitHeight: menuContent.height

        // Menu background
        Rectangle {
            id: menuContent
            width: root.menuWidth
            height: menuStack.currentItem ? menuStack.currentItem.implicitHeight + (root.menuPadding * 2) : 50
            color: Colors.background
            border.color: Colors.border
            border.width: 1
            radius: root.borderRadius

            opacity: TrayMenuState.menuOpen ? 1 : 0
            scale: TrayMenuState.menuOpen ? 1 : 0.95
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration }
            }

            Behavior on scale {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutQuad }
            }

            Behavior on height {
                NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutQuad }
            }

            StackView {
                id: menuStack
                anchors.fill: parent
                anchors.margins: root.menuPadding
                clip: true

                // Disable default animations to prevent flicker
                pushEnter: Transition { NumberAnimation { duration: 0 } }
                pushExit: Transition { NumberAnimation { duration: 0 } }
                popEnter: Transition { NumberAnimation { duration: 0 } }
                popExit: Transition { NumberAnimation { duration: 0 } }
            }
        }
    }

    // Menu level component - displays items from a QsMenuHandle
    Component {
        id: menuLevelComponent

        Item {
            id: menuLevel
            property var menuHandle

            implicitWidth: root.menuWidth - (root.menuPadding * 2)
            implicitHeight: contentColumn.implicitHeight

            QsMenuOpener {
                id: menuOpener
                menu: menuLevel.menuHandle
            }

            Column {
                id: contentColumn
                width: parent.width
                spacing: 2

                // Back button when in submenu
                Loader {
                    active: menuStack.depth > 1
                    width: parent.width
                    height: active ? root.itemHeight : 0

                    sourceComponent: Rectangle {
                        width: parent.width
                        height: root.itemHeight
                        color: backMouseArea.containsMouse ? Colors.backgroundAlt : "transparent"
                        radius: 4

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: root.itemPadding
                            anchors.rightMargin: root.itemPadding
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\u2190"
                                font.pixelSize: root.fontSize
                                color: Colors.text
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Back"
                                font.pixelSize: root.fontSize
                                color: Colors.text
                            }
                        }

                        MouseArea {
                            id: backMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: menuStack.pop()
                        }
                    }
                }

                // Separator after back button
                Loader {
                    active: menuStack.depth > 1
                    width: parent.width
                    height: active ? 9 : 0

                    sourceComponent: Item {
                        width: parent.width
                        height: 9

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - (root.itemPadding * 2)
                            height: 1
                            color: Colors.border
                        }
                    }
                }

                // Menu items
                Repeater {
                    model: menuOpener.children

                    delegate: Loader {
                        id: itemLoader
                        required property var modelData

                        width: contentColumn.width
                        height: modelData.isSeparator ? 9 : root.itemHeight

                        sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

                        Component {
                            id: separatorComponent

                            Item {
                                width: parent.width
                                height: 9

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - (root.itemPadding * 2)
                                    height: 1
                                    color: Colors.border
                                }
                            }
                        }

                        Component {
                            id: menuItemComponent

                            Rectangle {
                                width: parent.width
                                height: root.itemHeight
                                color: itemMouseArea.containsMouse && itemLoader.modelData.enabled ? Colors.backgroundAlt : "transparent"
                                radius: 4
                                opacity: itemLoader.modelData.enabled ? 1 : 0.5

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: root.itemPadding
                                    anchors.rightMargin: root.itemPadding
                                    spacing: 8

                                    // Icon
                                    Item {
                                        width: root.iconSize
                                        height: root.iconSize
                                        anchors.verticalCenter: parent.verticalCenter

                                        Image {
                                            anchors.fill: parent
                                            source: itemLoader.modelData.icon || ""
                                            sourceSize: Qt.size(root.iconSize, root.iconSize)
                                            visible: itemLoader.modelData.icon && itemLoader.modelData.icon !== ""
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            mipmap: true
                                        }
                                    }

                                    // Label
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - root.iconSize - 8 - (itemLoader.modelData.hasChildren ? 20 : 0)
                                        text: itemLoader.modelData.text || ""
                                        font.pixelSize: root.fontSize
                                        color: Colors.text
                                        elide: Text.ElideRight
                                    }

                                    // Submenu arrow
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: itemLoader.modelData.hasChildren
                                        text: "\u203a"
                                        font.pixelSize: root.fontSize + 4
                                        color: Colors.textSecondary
                                    }
                                }

                                MouseArea {
                                    id: itemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: itemLoader.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    onClicked: {
                                        if (!itemLoader.modelData.enabled) return

                                        if (itemLoader.modelData.hasChildren) {
                                            // Push submenu
                                            menuStack.push(menuLevelComponent.createObject(menuStack, {
                                                menuHandle: itemLoader.modelData
                                            }))
                                        } else {
                                            // Trigger action and close menu
                                            itemLoader.modelData.triggered()
                                            TrayMenuState.close()
                                        }
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 50 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
