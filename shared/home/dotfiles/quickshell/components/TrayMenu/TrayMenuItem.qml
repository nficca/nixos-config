pragma ComponentBehavior: Bound
import QtQuick
import "../.."

Rectangle {
    id: root

    required property var menuItem
    required property int itemHeight
    required property int itemPadding
    required property int iconSize
    required property int fontSize
    required property int itemSpacing

    signal triggered()
    signal submenuRequested(var handle)

    width: parent?.width ?? 0
    height: itemHeight
    color: itemMouseArea.containsMouse && menuItem.enabled ? Colors.backgroundAlt : "transparent"
    radius: 4
    opacity: menuItem.enabled ? 1 : 0.5

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
                source: root.menuItem.icon || ""
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                visible: root.menuItem.icon && root.menuItem.icon !== ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        // Label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - root.iconSize - root.itemSpacing - (root.menuItem.hasChildren ? 20 : 0)
            text: root.menuItem.text || ""
            font.pixelSize: root.fontSize
            color: Colors.text
            elide: Text.ElideRight
        }

        // Submenu arrow
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.menuItem.hasChildren
            text: "\u203a"
            font.pixelSize: root.fontSize + 4
            color: Colors.textSecondary
        }
    }

    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.menuItem.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            if (!root.menuItem.enabled)
                return;
            if (root.menuItem.hasChildren) {
                root.submenuRequested(root.menuItem);
            } else {
                root.menuItem.triggered();
                root.triggered();
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.hover
        }
    }
}
