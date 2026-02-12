import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

Row {
    id: root

    spacing: 8

    // We need to lookup the desktop entry for the focused window because that
    // holds useful information about the app like it's icon name.
    //
    // We include a reference to DesktopEntries.applications because we want the
    // whole expression to re-evaluate once the entries finish loading for the
    // first time. Without this, the desktop entry won't be found until the
    // focused window changes.
    property var desktopEntry: DesktopEntries.applications && Niri.focusedWindow?.appId ? DesktopEntries.heuristicLookup(Niri.focusedWindow.appId) : null

    IconImage {
        width: 32
        height: 32
        anchors.verticalCenter: parent.verticalCenter
        source: root.desktopEntry?.icon ? Quickshell.iconPath(root.desktopEntry.icon) : ""
        visible: !!root.desktopEntry?.icon
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Niri.focusedWindow?.title ?? ""
        font.pixelSize: 14
        color: Colors.foreground
        elide: Text.ElideRight
    }
}
