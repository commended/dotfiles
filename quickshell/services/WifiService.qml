import QtQuick
import Quickshell.Io

Item {
    id: wifiService
    
    property bool wifiEnabled: true
    property string wifiConnected: ""
    property var wifiNetworks: []
    
    function refresh() {
        wifiNetworks = []
        wifiConnected = ""
        wifiStatusProc.running = true
        wifiConnectedProc.running = true
        wifiListProc.running = true
    }
    
    function connectNetwork(ssid) {
        wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", ssid]
        wifiConnectProc.running = true
    }
    
    function disconnectNetwork() {
        wifiDisconnectProc.running = true
    }
    
    function toggleWifi(enable) {
        wifiToggleProc.command = ["nmcli", "radio", "wifi", enable ? "on" : "off"]
        wifiToggleProc.running = true
    }
    
    Process {
        id: wifiStatusProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: SplitParser {
            onRead: data => wifiEnabled = (data?.trim() === "enabled")
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: wifiConnectedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data?.split(":")
                if (parts?.length >= 2 && parts[1] === "802-11-wireless") {
                    wifiConnected = parts[0]
                }
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: wifiListProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "device", "wifi", "list"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var parts = data.split(":")
                if (parts.length >= 4 && parts[0] !== "") {
                    var newNetworks = wifiNetworks.slice()
                    if (!newNetworks.some(n => n.ssid === parts[0])) {
                        newNetworks.push({
                            ssid: parts[0],
                            signal: parseInt(parts[1]) || 0,
                            security: parts[2] || "",
                            connected: parts[3] === "*"
                        })
                        wifiNetworks = newNetworks
                    }
                }
            }
        }
    }
    
    Process {
        id: wifiConnectProc
        command: ["nmcli", "device", "wifi", "connect", ""]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Process {
        id: wifiDisconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Process {
        id: wifiToggleProc
        command: ["nmcli", "radio", "wifi", "on"]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Timer {
        id: wifiRefreshTimer
        interval: 1000
        onTriggered: refresh()
    }
}
