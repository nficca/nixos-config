import QtQuick
import ".."

Row {
    spacing: 8
    leftPadding: 10
    rightPadding: 10

    Repeater {
        model: Niri.workspaces

        Rectangle {
            id: workspaceItem
            required property var modelData

            width: 12
            height: 12
            radius: 6

            color: workspaceItem.modelData.isFocused ? Colors.active : Colors.inactive
            opacity: workspaceItem.modelData.isFocused ? 1.0 : 0.6
            scale: workspaceItem.modelData.isFocused ? 1.3 : (mouseArea.containsMouse ? 1.1 : 1.0)

            Behavior on scale {
                NumberAnimation { duration: Appearance.anim.smooth; easing.type: Easing.InOutQuad }
            }

            Behavior on opacity {
                NumberAnimation { duration: Appearance.anim.smooth }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspaceById(workspaceItem.modelData.id)
            }
        }
    }
}
