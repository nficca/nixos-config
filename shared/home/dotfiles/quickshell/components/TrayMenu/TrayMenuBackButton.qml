pragma ComponentBehavior: Bound
import QtQuick
import "../.."

Rectangle {
    id: root

    required property int itemHeight
    required property int itemPadding
    required property int fontSize
    required property int itemSpacing

    signal backClicked()

    width: parent?.width ?? 0
    height: itemHeight
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
        onClicked: root.backClicked()
    }
}
