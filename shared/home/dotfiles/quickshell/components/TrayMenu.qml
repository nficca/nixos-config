pragma ComponentBehavior: Bound
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
    readonly property int animationDuration: 120
    readonly property int menuOffsetY: 5
    readonly property int itemSpacing: 8

    // Position tracking for menu
    property real menuX: 0
    property real menuY: 0
    property var menuWindow: null
    property bool menuWasOpen: false
    property bool menuReady: false
    property bool animatingOut: false
    property var pendingOpen: null

    function applyMenuOpen(handle, anchor) {
        if (!anchor)
            return;

        var anchorPos = anchor.mapToItem(null, 0, 0);
        root.menuX = anchorPos.x + anchor.width / 2 - root.menuWidth / 2;
        root.menuY = anchorPos.y + anchor.height + root.menuOffsetY;
        root.menuWindow = anchor.QsWindow.window;

        menuStack.clear();
        menuStack.push(menuLevelComponent.createObject(menuStack, {
            menuHandle: handle
        }));
    }

    Connections {
        target: TrayMenuState
        function onOpenRequested(handle, anchor) {
            if (root.menuWasOpen && root.menuReady) {
                // Switching menus - animate out, then update position
                root.pendingOpen = {
                    handle: handle,
                    anchor: anchor
                };
                switchAnimation.start();
            } else {
                // Fresh open - update position immediately
                root.applyMenuOpen(handle, anchor);
                root.menuWasOpen = true;
                root.menuReady = true;
                openAnimation.start();
            }
        }

        function onCloseRequested() {
            root.animatingOut = true;
            closeAnimation.start();
        }
    }

    SequentialAnimation {
        id: openAnimation

        NumberAnimation {
            target: menuContent
            property: "opacity"
            to: 1
            duration: root.animationDuration
            easing.type: Easing.OutQuad
        }
    }

    SequentialAnimation {
        id: closeAnimation

        NumberAnimation {
            target: menuContent
            property: "opacity"
            to: 0
            duration: root.animationDuration
            easing.type: Easing.OutQuad
        }

        ScriptAction {
            script: {
                root.animatingOut = false;
                root.menuWasOpen = false;
                root.menuReady = false;
            }
        }
    }

    SequentialAnimation {
        id: switchAnimation

        NumberAnimation {
            target: menuContent
            property: "opacity"
            to: 0
            duration: root.animationDuration
            easing.type: Easing.OutQuad
        }

        ScriptAction {
            script: {
                if (root.pendingOpen) {
                    root.applyMenuOpen(root.pendingOpen.handle, root.pendingOpen.anchor);
                    root.pendingOpen = null;
                    openAnimation.start();
                }
            }
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
        visible: (TrayMenuState.menuOpen || root.animatingOut) && root.menuReady
        anchor.window: root.menuWindow
        anchor.rect.x: root.menuX
        anchor.rect.y: root.menuY
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

            opacity: 0
            scale: TrayMenuState.menuOpen ? 1 : 0.95
            transformOrigin: Item.Top

            Behavior on scale {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutQuad
                }
            }

            StackView {
                id: menuStack
                anchors.fill: parent
                anchors.margins: root.menuPadding
                clip: true

                // Disable default animations to prevent flicker
                pushEnter: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                pushExit: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                popEnter: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                popExit: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
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

            // Separator component - reused for back-button separator and menu item separators
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
                            spacing: root.itemSpacing

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
                    sourceComponent: separatorComponent
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

                        // Menu item component - defined inside delegate to access itemLoader.modelData
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
                                    spacing: root.itemSpacing

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
                                        width: parent.width - root.iconSize - root.itemSpacing - (itemLoader.modelData.hasChildren ? 20 : 0)
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
                                        if (!itemLoader.modelData.enabled)
                                            return;
                                        if (itemLoader.modelData.hasChildren) {
                                            // Push submenu
                                            menuStack.push(menuLevelComponent.createObject(menuStack, {
                                                menuHandle: itemLoader.modelData
                                            }));
                                        } else {
                                            // Trigger action and close menu
                                            itemLoader.modelData.triggered();
                                            TrayMenuState.close();
                                        }
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 50
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
