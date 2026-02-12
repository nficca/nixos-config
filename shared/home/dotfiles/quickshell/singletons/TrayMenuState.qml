pragma Singleton
import QtQuick

QtObject {
    property bool menuOpen: false
    property var menuHandle: null
    property Item anchorItem: null

    signal openRequested(var handle, Item anchor)
    signal closeRequested()

    function open(handle, anchor) {
        // If switching between menus, close first to avoid visual glitches
        if (menuOpen) {
            menuOpen = false
        }
        menuHandle = handle
        anchorItem = anchor
        menuOpen = true
        openRequested(handle, anchor)
    }

    function close() {
        menuOpen = false
        menuHandle = null
        anchorItem = null
        closeRequested()
    }
}
