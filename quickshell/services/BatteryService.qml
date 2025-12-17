import QtQuick
import Quickshell.Io

Item {
    id: batteryService
    
    property int batteryLevel: 0
    property bool batteryCharging: false
    property string powerProfile: "balanced"
    property bool powerProfilesAvailable: false
    property int systemUptime: 0
    
    function refresh() {
        batteryProc.running = true
        batteryStatusProc.running = true
        powerProfileProc.running = true
        uptimeProc.running = true
    }
    
    function setProfile(profile) {
        powerProfileSetProc.command = ["sh", "-c", "powerprofilesctl set " + profile + " 2>&1"]
        powerProfileSetProc.running = true
    }
    
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
        command: ["sh", "-c", ""]
        onRunningChanged: if (!running) powerProfileRefreshTimer.start()
    }
    
    Timer {
        id: powerProfileRefreshTimer
        interval: 500
        onTriggered: powerProfileProc.running = true
    }
}
