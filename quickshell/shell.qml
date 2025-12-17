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
    
    // ===== CALENDAR STATE =====
    property date currentDate: new Date()
    
    // Helper function to close all menus
    function closeAllMenus() {
        volumeMenuOpen = false
        bluetoothMenuOpen = false
        wifiMenuOpen = false
        calendarMenuOpen = false
        batteryMenuOpen = false
    }
    
    // ===== SERVICES =====
    VolumeService {
        id: volumeService
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
    
    // ===== CONSOLIDATED TIMERS =====
    Timer {
        interval: 1000
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
        
        onToggleBarExpanded: {
            root.barExpanded = !root.barExpanded
        }
        onToggleTrayCollapsed: {
            root.trayCollapsed = !root.trayCollapsed
        }
        onOpenVolumeMenu: {
            volumeMenuOpen = !volumeMenuOpen
            wifiMenuOpen = false
            bluetoothMenuOpen = false
            calendarMenuOpen = false
        }
        onOpenBluetoothMenu: {
            bluetoothMenuOpen = !bluetoothMenuOpen
            wifiMenuOpen = false
            if (bluetoothMenuOpen) {
                bluetoothService.refresh()
            }
        }
        onOpenWifiMenu: {
            wifiMenuOpen = !wifiMenuOpen
            bluetoothMenuOpen = false
            if (wifiMenuOpen) {
                wifiService.refresh()
            }
        }
        onOpenBatteryMenu: {
            batteryMenuOpen = !batteryMenuOpen
            wifiMenuOpen = false
            bluetoothMenuOpen = false
            volumeMenuOpen = false
        }
        onOpenCalendarMenu: {
            calendarMenuOpen = !calendarMenuOpen
            bluetoothMenuOpen = false
            wifiMenuOpen = false
        }
    }
}
