pragma Singleton
import QtQuick

QtObject {
    // State constants
    readonly property int stateClosed: 0
    readonly property int stateOpening: 1
    readonly property int stateOpen: 2
    readonly property int stateSwitching: 3
    readonly property int stateClosing: 4

    property int state: stateClosed

    // Computed visibility for bindings
    readonly property bool isVisible: state !== stateClosed

    // Current menu data
    property var menuHandle: null
    property Item anchorItem: null

    // Pending data for menu-to-menu transitions
    property var pendingHandle: null
    property Item pendingAnchor: null

    // Animation trigger signals
    signal openAnimationRequested()
    signal closeAnimationRequested()
    signal switchAnimationRequested()

    function open(handle, anchor) {
        if (state === stateOpen) {
            // Currently open - switch to new menu
            pendingHandle = handle
            pendingAnchor = anchor
            state = stateSwitching
            switchAnimationRequested()
        } else if (state === stateClosed) {
            // Fresh open
            menuHandle = handle
            anchorItem = anchor
            state = stateOpening
            openAnimationRequested()
        }
    }

    function close() {
        if (state === stateOpen || state === stateOpening) {
            state = stateClosing
            closeAnimationRequested()
        }
    }

    function onOpenComplete() {
        if (state === stateOpening) {
            state = stateOpen
        }
    }

    function onCloseComplete() {
        if (state === stateClosing) {
            menuHandle = null
            anchorItem = null
            state = stateClosed
        }
    }

    function onSwitchComplete() {
        if (state === stateSwitching) {
            menuHandle = pendingHandle
            anchorItem = pendingAnchor
            pendingHandle = null
            pendingAnchor = null
            state = stateOpening
            openAnimationRequested()
        }
    }
}
