pragma ComponentBehavior: Bound
import QtQuick
import "../.."

Item {
    id: root

    required property int itemPadding

    width: parent?.width ?? 0
    height: 9

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - (root.itemPadding * 2)
        height: 1
        color: Appearance.colors.border
    }
}
