import QtQuick
import Quickshell.Io

Item {
    id: bluetoothService
    
    property var bluetoothDevices: []
    property bool bluetoothEnabled: true
    
    function refresh() {
        bluetoothDevices = []
        btStatusProc.running = true
        btListProc.running = true
        btConnectedProc.running = true
    }
    
    function connectDevice(mac) {
        btConnectProc.command = ["bluetoothctl", "connect", mac]
        btConnectProc.running = true
    }
    
    function disconnectDevice(mac) {
        btDisconnectProc.command = ["bluetoothctl", "disconnect", mac]
        btDisconnectProc.running = true
    }
    
    function toggleBluetooth(enable) {
        btToggleProc.command = ["bluetoothctl", "power", enable ? "on" : "off"]
        btToggleProc.running = true
    }
    
    Process {
        id: btListProc
        command: ["bluetoothctl", "devices"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var match = data.match(/Device\s+([A-F0-9:]+)\s+(.+)/)
                if (match) {
                    var newDevices = bluetoothDevices.slice()
                    if (!newDevices.some(d => d.mac === match[1])) {
                        newDevices.push({mac: match[1], name: match[2], connected: false})
                        bluetoothDevices = newDevices
                    }
                }
            }
        }
    }
    
    Process {
        id: btStatusProc
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                if (data?.includes("Powered: yes")) bluetoothEnabled = true
                else if (data?.includes("Powered: no")) bluetoothEnabled = false
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: btConnectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var match = data.match(/Device\s+([A-F0-9:]+)\s+(.+)/)
                if (match) {
                    var newDevices = bluetoothDevices.slice()
                    for (var i = 0; i < newDevices.length; i++) {
                        if (newDevices[i].mac === match[1]) newDevices[i].connected = true
                    }
                    bluetoothDevices = newDevices
                }
            }
        }
    }
    
    Process {
        id: btConnectProc
        command: ["bluetoothctl", "connect", ""]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Process {
        id: btDisconnectProc
        command: ["bluetoothctl", "disconnect", ""]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Process {
        id: btToggleProc
        command: ["bluetoothctl", "power", "on"]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Timer {
        id: btRefreshTimer
        interval: 500
        onTriggered: refresh()
    }
}
