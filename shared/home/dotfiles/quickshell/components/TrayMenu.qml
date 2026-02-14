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

            Column {
                id: contentColumn
                width: parent.width
                spacing: 2

                // Back button when in submenu
                Loader {
                    active: menuStack.depth > 1
                    width: parent.width
                    height: active ? root.itemHeight : 0

                    sourceComponent: TrayMenuBackButton {
                        itemHeight: root.itemHeight
                        itemPadding: root.itemPadding
                        fontSize: root.fontSize
                        itemSpacing: root.itemSpacing
                        onBackClicked: menuStack.pop()
                    }
                }

                // Separator after back button
                Loader {
                    active: menuStack.depth > 1
                    width: parent.width
                    height: active ? 9 : 0

                    sourceComponent: TrayMenuSeparator {
                        itemPadding: root.itemPadding
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

                            TrayMenuSeparator {
                                itemPadding: root.itemPadding
                            }
                        }

                        Component {
                            id: menuItemComponent

                            TrayMenuItem {
                                menuItem: itemLoader.modelData
                                itemHeight: root.itemHeight
                                itemPadding: root.itemPadding
                                iconSize: root.iconSize
                                fontSize: root.fontSize
                                itemSpacing: root.itemSpacing

                                onTriggered: TrayMenuState.close()
                                onSubmenuRequested: handle => {
                                    menuStack.push(menuLevelComponent.createObject(menuStack, {
                                        menuHandle: handle
                                    }));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
