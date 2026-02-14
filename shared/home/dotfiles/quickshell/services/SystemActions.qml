pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    function lock() { lockProcess.running = true }
    function logout() { logoutProcess.running = true }
    function suspend() { suspendProcess.running = true }
    function reboot() { rebootProcess.running = true }
    function shutdown() { shutdownProcess.running = true }

    property var lockProcess: Process { command: ["hyprlock"] }
    property var logoutProcess: Process { command: ["niri", "msg", "action", "quit"] }
    property var suspendProcess: Process { command: ["systemctl", "suspend"] }
    property var rebootProcess: Process { command: ["systemctl", "reboot"] }
    property var shutdownProcess: Process { command: ["systemctl", "poweroff"] }
}
