pragma Singleton
import QtQuick

QtObject {
    property bool menuOpen: false
    property var menuHandle: null
    property Item anchorItem: null

    signal openRequested(var handle, Item anchor)
    signal closeRequested()

    function open(handle, anchor) {
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
