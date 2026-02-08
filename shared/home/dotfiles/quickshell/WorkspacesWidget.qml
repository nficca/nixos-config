import QtQuick

Row {
    spacing: 8

    Repeater {
        model: Niri.workspaces

        Rectangle {
            id: workspaceItem
            required property var modelData

            width: 100
            height: 30

            Text {
                anchors.centerIn: parent
                text: "Workspace " + workspaceItem.modelData.index + (workspaceItem.modelData.isFocused ? " (focused)" : "")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Niri.focusWorkspaceById(workspaceItem.modelData.id)
            }
        }
    }
}
