pragma Singleton
import QtQuick

QtObject {
    property string currentName: ""
    property Item anchorItem: null
    property var anchorWindow: null

    readonly property bool hasCurrent: currentName !== ""

    function open(name: string, anchor: Item, window: var): void {
        currentName = name
        anchorItem = anchor
        anchorWindow = window
    }

    function close(): void {
        currentName = ""
        anchorItem = null
        anchorWindow = null
    }
}
