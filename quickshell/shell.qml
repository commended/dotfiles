import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "components"
import "services"

ShellRoot {
    id: root
    
    // ===== BAR STATE =====
    property bool barExpanded: true
    property bool trayCollapsed: false
    
    // ===== MENU STATE =====
    property bool volumeMenuOpen: false
    property bool bluetoothMenuOpen: false
    property bool batteryMenuOpen: false
    property bool wifiMenuOpen: false
    property bool calendarMenuOpen: false
    property bool brightnessMenuOpen: false
    
    // ===== NOTIFICATION STATE =====
    property bool notificationVisible: false
    property string notificationType: ""
    property int notificationValue: 0
    property string notificationBluetoothDevice: ""
    property bool notificationBluetoothConnected: false
    
    // ===== CHANGE DETECTION =====
    property int previousVolumeLevel: -1
    property int previousBrightnessLevel: -1
    property var previousBluetoothDevices: []
    
    // ===== CALENDAR STATE =====
    property date currentDate: new Date()
    
    // ===== HELPER FUNCTIONS =====
    function closeAllMenus() {
        volumeMenuOpen = false
        bluetoothMenuOpen = false
        wifiMenuOpen = false
        calendarMenuOpen = false
        batteryMenuOpen = false
        brightnessMenuOpen = false
    }
    
    function openMenu(menuName) {
        closeAllMenus()
        switch (menuName) {
            case "volume": volumeMenuOpen = true; break
            case "bluetooth": 
                bluetoothMenuOpen = true
                bluetoothService.refresh()
                break
            case "wifi":
                wifiMenuOpen = true
                wifiService.refresh()
                break
            case "battery": batteryMenuOpen = true; break
            case "calendar": calendarMenuOpen = true; break
            case "brightness": brightnessMenuOpen = true; break
        }
    }
    
    function toggleMenu(menuName) {
        var wasOpen = false
        switch (menuName) {
            case "volume": wasOpen = volumeMenuOpen; break
            case "bluetooth": wasOpen = bluetoothMenuOpen; break
            case "wifi": wasOpen = wifiMenuOpen; break
            case "battery": wasOpen = batteryMenuOpen; break
            case "calendar": wasOpen = calendarMenuOpen; break
            case "brightness": wasOpen = brightnessMenuOpen; break
        }
        
        if (wasOpen) {
            closeAllMenus()
        } else {
            openMenu(menuName)
        }
    }
    
    function showNotification(type, value, btDevice, btConnected) {
        notificationType = type
        notificationValue = value || 0
        notificationBluetoothDevice = btDevice || ""
        notificationBluetoothConnected = btConnected || false
        notificationVisible = true
        notificationTimer.restart()
    }
    
    // ===== SERVICES =====
    VolumeService {
        id: volumeService
        
        onVolumeLevelChanged: {
            if (previousVolumeLevel !== -1 && previousVolumeLevel !== volumeLevel && !isDraggingVolume) {
                showNotification("volume", volumeLevel)
            }
            previousVolumeLevel = volumeLevel
        }
    }
    
    BluetoothService {
        id: bluetoothService
    }
    
    BatteryService {
        id: batteryService
    }
    
    WiFiService {
        id: wifiService
    }
    
    MediaService {
        id: mediaService
    }
    
    BrightnessService {
        id: brightnessService
        
        onBrightnessLevelChanged: {
            if (previousBrightnessLevel !== -1 && previousBrightnessLevel !== brightnessLevel && !isDraggingBrightness) {
                showNotification("brightness", brightnessLevel)
            }
            previousBrightnessLevel = brightnessLevel
        }
    }
    
    // ===== NOTIFICATION TIMER =====
    Timer {
        id: notificationTimer
        interval: 3000
        onTriggered: {
            notificationVisible = false
        }
    }
    
    // Initialize previous values after a short delay
    Timer {
        id: initTimer
        interval: 2000
        running: true
        onTriggered: {
            previousVolumeLevel = volumeService.volumeLevel
            previousBrightnessLevel = brightnessService.brightnessLevel
            previousBluetoothDevices = JSON.parse(JSON.stringify(bluetoothService.bluetoothDevices))
            console.log("Notification system initialized")
        }
    }
    
    // Watch for Bluetooth connection changes (not when menu opens)
    Timer {
        id: bluetoothWatcher
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (previousBluetoothDevices.length === 0 || bluetoothMenuOpen) {
                return
            }
            
            var currentDevices = bluetoothService.bluetoothDevices
            
            for (var i = 0; i < currentDevices.length; i++) {
                var device = currentDevices[i]
                var previousDevice = null
                
                for (var j = 0; j < previousBluetoothDevices.length; j++) {
                    if (previousBluetoothDevices[j].mac === device.mac) {
                        previousDevice = previousBluetoothDevices[j]
                        break
                    }
                }
                
                if (previousDevice && device.connected !== previousDevice.connected) {
                    console.log("Bluetooth state changed:", device.name, device.connected)
                    showNotification("bluetooth", 0, device.name, device.connected)
                    break
                }
            }
            
            previousBluetoothDevices = JSON.parse(JSON.stringify(currentDevices))
        }
    }
    
    // ===== CONSOLIDATED TIMERS =====
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            volumeService.refresh()
            mediaService.refresh()
        }
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryService.refresh()
        }
    }
    
    // ===== NOTIFICATION POPUP =====
    NotificationPopup {
        barWindow: bar
        barExpanded: root.barExpanded
        notifVisible: notificationVisible
        notificationType: root.notificationType
        value: root.notificationValue
        bluetoothDeviceName: root.notificationBluetoothDevice
        bluetoothConnected: root.notificationBluetoothConnected
    }
    
    // ===== POPUP MENUS =====
    VolumeMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: volumeMenuOpen
        volumeLevel: volumeService.volumeLevel
        targetVolumeLevel: volumeService.targetVolumeLevel
        volumeMuted: volumeService.volumeMuted
        isDraggingVolume: volumeService.isDraggingVolume
        mediaTitle: mediaService.mediaTitle
        mediaArtist: mediaService.mediaArtist
        mediaThumbnail: mediaService.mediaThumbnail
        mediaPlaying: mediaService.mediaPlaying
        mediaLength: mediaService.mediaLength
        mediaPosition: mediaService.mediaPosition
        
        onVolumeChanged: (level) => {
            volumeService.targetVolumeLevel = level
        }
        onVolumeDragStarted: {
            volumeService.isDraggingVolume = true
        }
        onVolumeDragEnded: (level) => {
            volumeService.volumeLevel = level
            volumeService.targetVolumeLevel = level
            volumeService.setVolume(level)
            volumeService.isDraggingVolume = false
        }
        onMediaControl: (action) => {
            mediaService.control(action)
        }
    }
    
    BluetoothMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: bluetoothMenuOpen
        bluetoothDevices: bluetoothService.bluetoothDevices
        bluetoothEnabled: bluetoothService.bluetoothEnabled
        
        onToggleBluetooth: (enable) => {
            bluetoothService.toggleBluetooth(enable)
        }
        onConnectDevice: (mac) => {
            bluetoothService.connectDevice(mac)
        }
        onDisconnectDevice: (mac) => {
            bluetoothService.disconnectDevice(mac)
        }
    }
    
    WiFiMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: wifiMenuOpen
        wifiEnabled: wifiService.wifiEnabled
        wifiConnected: wifiService.wifiConnected
        wifiNetworks: wifiService.wifiNetworks
        
        onToggleWifi: (enable) => {
            wifiService.toggleWifi(enable)
        }
        onConnectNetwork: (ssid) => {
            wifiService.connectNetwork(ssid)
        }
        onDisconnectNetwork: {
            wifiService.disconnectNetwork()
        }
    }
    
    CalendarMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: calendarMenuOpen
        currentDate: root.currentDate
        
        onDateChanged: (newDate) => {
            root.currentDate = newDate
        }
    }
    
    BatteryMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: batteryMenuOpen
        batteryLevel: batteryService.batteryLevel
        batteryCharging: batteryService.batteryCharging
        powerProfile: batteryService.powerProfile
        powerProfilesAvailable: batteryService.powerProfilesAvailable
        systemUptime: batteryService.systemUptime
        
        onSetProfile: (profile) => {
            batteryService.setProfile(profile)
        }
    }
    
    BrightnessMenu {
        barWindow: bar
        barExpanded: root.barExpanded
        menuOpen: brightnessMenuOpen
        brightnessLevel: brightnessService.brightnessLevel
        targetBrightnessLevel: brightnessService.targetBrightnessLevel
        isDraggingBrightness: brightnessService.isDraggingBrightness
        
        onBrightnessChanged: (level) => {
            brightnessService.targetBrightnessLevel = level
            brightnessService.getMonitor("active")?.setBrightness(level / 100)
        }
        onBrightnessDragStarted: {
            brightnessService.isDraggingBrightness = true
        }
        onBrightnessDragEnded: (level) => {
            brightnessService.getMonitor("active")?.setBrightness(level / 100)
            brightnessService.targetBrightnessLevel = level
            brightnessService.isDraggingBrightness = false
        }
    }
    
    // ===== MAIN BAR =====
    Bar {
        id: bar
        barExpanded: root.barExpanded
        trayCollapsed: root.trayCollapsed
        wifiEnabled: wifiService.wifiEnabled
        wifiConnected: wifiService.wifiConnected
        bluetoothEnabled: bluetoothService.bluetoothEnabled
        batteryLevel: batteryService.batteryLevel
        batteryCharging: batteryService.batteryCharging
        volumeLevel: volumeService.volumeLevel
        volumeMuted: volumeService.volumeMuted
        brightnessLevel: brightnessService.brightnessLevel
        
        onToggleBarExpanded: root.barExpanded = !root.barExpanded
        onToggleTrayCollapsed: root.trayCollapsed = !root.trayCollapsed
        onOpenVolumeMenu: root.toggleMenu("volume")
        onOpenBluetoothMenu: root.toggleMenu("bluetooth")
        onOpenWifiMenu: root.toggleMenu("wifi")
        onOpenBatteryMenu: root.toggleMenu("battery")
        onOpenCalendarMenu: root.toggleMenu("calendar")
        onOpenBrightnessMenu: root.toggleMenu("brightness")
    }
}
