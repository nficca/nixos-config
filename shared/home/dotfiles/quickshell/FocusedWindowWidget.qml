import QtQuick

Row {
    spacing: 8

    Image {
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        source: Niri.focusedWindow?.iconPath ? "file://" + Niri.focusedWindow.iconPath : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: Niri.focusedWindow?.iconPath ? true : false
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Niri.focusedWindow?.title ?? ""
        font.pixelSize: 14
        color: Colors.foreground
        elide: Text.ElideRight
    }
}
