import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    // Bar state
    property bool barExpanded: true
    property bool trayCollapsed: false
    
    // Volume
    property int volumeLevel: 0
    property bool volumeMuted: false
    property bool volumeMenuOpen: false
    property int targetVolumeLevel: volumeLevel
    property bool isDraggingVolume: false
    
    // Bluetooth
    property bool bluetoothMenuOpen: false
    property var bluetoothDevices: []
    property bool bluetoothEnabled: true
    
    // Battery
    property int batteryLevel: 0
    property bool batteryCharging: false
    property bool batteryMenuOpen: false
    property string powerProfile: "balanced"
    property bool powerProfilesAvailable: false
    property int systemUptime: 0
    
    // WiFi
    property bool wifiMenuOpen: false
    property bool wifiEnabled: true
    property string wifiConnected: ""
    property var wifiNetworks: []
    
    // Calendar
    property bool calendarMenuOpen: false
    property date currentDate: new Date()
    
    // Media
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaThumbnail: ""
    property bool mediaPlaying: false
    property int mediaLength: 0
    property int mediaPosition: 0
    
    // Helper function to close all menus
    function closeAllMenus() {
        volumeMenuOpen = false
        bluetoothMenuOpen = false
        wifiMenuOpen = false
        calendarMenuOpen = false
        batteryMenuOpen = false
    }
    
    // ===== VOLUME PROCESSES =====
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match && !isDraggingVolume) {
                    var newLevel = Math.round(parseFloat(match[1]) * 100)
                    volumeLevel = newLevel
                    targetVolumeLevel = newLevel
                }
                volumeMuted = data.includes("[MUTED]")
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: volWatcher
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered 'sink'"]
        stdout: SplitParser {
            onRead: data => {
                if (!isDraggingVolume) volProc.running = true
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: volSetProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0"]
        function setVolume(level) {
            command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (level / 100).toFixed(2)]
            running = true
        }
    }
    
    // ===== BLUETOOTH PROCESSES =====
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
        property string targetMac: ""
        command: ["bluetoothctl", "connect", targetMac]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Process {
        id: btDisconnectProc
        property string targetMac: ""
        command: ["bluetoothctl", "disconnect", targetMac]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Process {
        id: btToggleProc
        property bool enabling: true
        command: ["bluetoothctl", "power", enabling ? "on" : "off"]
        onRunningChanged: if (!running) btRefreshTimer.start()
    }
    
    Timer {
        id: btRefreshTimer
        interval: 500
        onTriggered: refreshBluetooth()
    }
    
    function refreshBluetooth() {
        bluetoothDevices = []
        btStatusProc.running = true
        btListProc.running = true
        btConnectedProc.running = true
    }
    
    // ===== BATTERY PROCESSES =====
    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                var level = parseInt(data?.trim())
                if (!isNaN(level)) batteryLevel = level
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: batteryStatusProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Unknown"]
        stdout: SplitParser {
            onRead: data => batteryCharging = (data?.trim() === "Charging")
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: uptimeProc
        command: ["sh", "-c", "cat /proc/uptime | awk '{print int($1)}'"]
        stdout: SplitParser {
            onRead: data => {
                var seconds = parseInt(data?.trim())
                if (!isNaN(seconds)) systemUptime = seconds
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: powerProfileProc
        command: ["sh", "-c", "powerprofilesctl get 2>/dev/null || echo unavailable"]
        stdout: SplitParser {
            onRead: data => {
                var profile = data?.trim()
                if (profile === "unavailable") {
                    powerProfilesAvailable = false
                } else if (["performance", "balanced", "power-saver"].includes(profile)) {
                    powerProfilesAvailable = true
                    powerProfile = profile
                }
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: powerProfileSetProc
        property string profile: ""
        command: ["sh", "-c", ""]
        onRunningChanged: if (!running) powerProfileRefreshTimer.start()
        function setProfile(prof) {
            profile = prof
            command = ["sh", "-c", "powerprofilesctl set " + prof + " 2>&1"]
            running = true
        }
    }
    
    Timer {
        id: powerProfileRefreshTimer
        interval: 500
        onTriggered: powerProfileProc.running = true
    }
    
    // ===== WIFI PROCESSES =====
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
        property string targetSSID: ""
        command: ["nmcli", "device", "wifi", "connect", targetSSID]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Process {
        id: wifiDisconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Process {
        id: wifiToggleProc
        property bool enabling: true
        command: ["nmcli", "radio", "wifi", enabling ? "on" : "off"]
        onRunningChanged: if (!running) wifiRefreshTimer.start()
    }
    
    Timer {
        id: wifiRefreshTimer
        interval: 1000
        onTriggered: refreshWifi()
    }
    
    function refreshWifi() {
        wifiNetworks = []
        wifiConnected = ""
        wifiStatusProc.running = true
        wifiConnectedProc.running = true
        wifiListProc.running = true
    }
    
    // ===== MEDIA PROCESSES =====
    Process {
        id: mediaInfoProc
        command: ["playerctl", "metadata", "--format", "{{title}}|||{{artist}}|||{{mpris:artUrl}}|||{{status}}|||{{mpris:length}}|||{{position}}"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") {
                    mediaTitle = ""
                    return
                }
                var parts = data.split("|||")
                if (parts.length >= 6) {
                    mediaTitle = parts[0] || ""
                    mediaArtist = parts[1] || ""
                    mediaThumbnail = parts[2] || ""
                    mediaPlaying = parts[3] === "Playing"
                    mediaLength = parseInt(parts[4]) || 0
                    mediaPosition = parseInt(parts[5]) || 0
                }
            }
        }
        stderr: SplitParser {
            onRead: data => mediaTitle = ""
        }
    }
    
    Process {
        id: mediaControlProc
        property string action: ""
        command: ["playerctl", action]
    }
    
    // ===== CONSOLIDATED TIMERS =====
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!isDraggingVolume) volProc.running = true
            mediaInfoProc.running = true
        }
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryProc.running = true
            batteryStatusProc.running = true
            powerProfileProc.running = true
            uptimeProc.running = true
        }
    }
    
    // ===== VOLUME MENU =====
    VolumeMenu {
        barWindow: bar
        barExpanded: barExpanded
        volumeLevel: volumeLevel
        volumeMuted: volumeMuted
        volumeMenuOpen: volumeMenuOpen
        targetVolumeLevel: targetVolumeLevel
        isDraggingVolume: isDraggingVolume
        mediaTitle: mediaTitle
        mediaArtist: mediaArtist
        mediaThumbnail: mediaThumbnail
        mediaPlaying: mediaPlaying
        mediaLength: mediaLength
        mediaPosition: mediaPosition
        
        onUpdateTargetVolumeLevel: function(level) { targetVolumeLevel = level }
        onUpdateVolumeLevel: function(level) { volumeLevel = level }
        onUpdateIsDraggingVolume: function(dragging) { isDraggingVolume = dragging }
        onMediaControlAction: function(action) {
            mediaControlProc.action = action
            mediaControlProc.running = true
        }
        onSetVolume: function(level) { volSetProc.setVolume(level) }
    }
    
    // ===== BLUETOOTH MENU =====
    BluetoothMenu {
        barWindow: bar
        barExpanded: barExpanded
        bluetoothMenuOpen: bluetoothMenuOpen
        bluetoothDevices: bluetoothDevices
        bluetoothEnabled: bluetoothEnabled
        
        onToggleBluetooth: function(enabling) {
            btToggleProc.enabling = enabling
            btToggleProc.running = true
        }
        onConnectDevice: function(mac) {
            btConnectProc.targetMac = mac
            btConnectProc.running = true
        }
        onDisconnectDevice: function(mac) {
            btDisconnectProc.targetMac = mac
            btDisconnectProc.running = true
        }
    }
    
    // ===== WIFI MENU =====
    WifiMenu {
        barWindow: bar
        barExpanded: barExpanded
        wifiMenuOpen: wifiMenuOpen
        wifiEnabled: wifiEnabled
        wifiConnected: wifiConnected
        wifiNetworks: wifiNetworks
        
        onToggleWifi: function(enabling) {
            wifiToggleProc.enabling = enabling
            wifiToggleProc.running = true
        }
        onConnectNetwork: function(ssid) {
            wifiConnectProc.targetSSID = ssid
            wifiConnectProc.running = true
        }
        onDisconnectNetwork: {
            wifiDisconnectProc.running = true
        }
    }
    
    // ===== CALENDAR MENU =====
    CalendarMenu {
        barWindow: bar
        barExpanded: barExpanded
        calendarMenuOpen: calendarMenuOpen
        currentDate: currentDate
        
        onUpdateCurrentDate: function(newDate) { currentDate = newDate }
    }
    
    // ===== BATTERY MENU =====
    BatteryMenu {
        barWindow: bar
        barExpanded: barExpanded
        batteryMenuOpen: batteryMenuOpen
        batteryLevel: batteryLevel
        batteryCharging: batteryCharging
        powerProfile: powerProfile
        powerProfilesAvailable: powerProfilesAvailable
        systemUptime: systemUptime
        
        onSetPowerProfile: function(profile) { powerProfileSetProc.setProfile(profile) }
    }
    
    // ===== MAIN BAR =====
    Bar {
        id: bar
        barExpanded: barExpanded
        trayCollapsed: trayCollapsed
        wifiEnabled: wifiEnabled
        wifiConnected: wifiConnected
        bluetoothEnabled: bluetoothEnabled
        batteryLevel: batteryLevel
        batteryCharging: batteryCharging
        volumeLevel: volumeLevel
        volumeMuted: volumeMuted
        
        onUpdateBarExpanded: function(expanded) { barExpanded = expanded }
        onUpdateTrayCollapsed: function(collapsed) { trayCollapsed = collapsed }
        onWifiMenuToggled: {
            wifiMenuOpen = !wifiMenuOpen
            bluetoothMenuOpen = false
            if (wifiMenuOpen) {
                refreshWifi()
            }
        }
        onBluetoothMenuToggled: {
            bluetoothMenuOpen = !bluetoothMenuOpen
            wifiMenuOpen = false
            if (bluetoothMenuOpen) {
                refreshBluetooth()
            }
        }
        onBatteryMenuToggled: {
            batteryMenuOpen = !batteryMenuOpen
            wifiMenuOpen = false
            bluetoothMenuOpen = false
            volumeMenuOpen = false
        }
        onVolumeMenuToggled: {
            volumeMenuOpen = !volumeMenuOpen
            wifiMenuOpen = false
            bluetoothMenuOpen = false
            calendarMenuOpen = false
        }
        onCalendarMenuToggled: {
            calendarMenuOpen = !calendarMenuOpen
            bluetoothMenuOpen = false
            wifiMenuOpen = false
        }
    }
}
