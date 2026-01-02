pragma Singleton
import QtQuick

QtObject {
    // ===== COLORS =====
    readonly property color background: "#1a1a1a"
    readonly property color surface: "#2a2a2a"
    readonly property color surfaceHover: "#404040"
    readonly property color surfaceActive: "#505050"
    readonly property color surfaceSubtle: "#353535"
    
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#888888"
    readonly property color textDisabled: "#666666"
    readonly property color textDanger: "#ff6b6b"
    
    readonly property color accent: "#ffffff"
    readonly property color accentText: "#1a1a1a"
    
    readonly property color separator: "#404040"
    
    // ===== TYPOGRAPHY =====
    readonly property string fontFamily: "JetBrains Mono Nerd Font"
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeDefault: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeXLarge: 20
    readonly property int fontSizeIcon: 18
    readonly property int fontSizeIconLarge: 24
    
    // ===== ANIMATIONS =====
    readonly property int animationDurationFast: 150
    readonly property int animationDurationNormal: 200
    readonly property int animationDurationSlow: 300
    
    // ===== SPACING =====
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 12
    readonly property int radiusRound: 18
    readonly property int radiusFull: 20
    
    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 12
    readonly property int spacingXLarge: 15
    
    readonly property int marginDefault: 10
    readonly property int marginMedium: 12
    readonly property int marginLarge: 15
    
    // ===== ICON HELPERS =====
    function getBatteryIcon(level: int, charging: bool): string {
        if (charging) return "󰂄"
        if (level >= 90) return "󰁹"
        if (level >= 80) return "󰂂"
        if (level >= 70) return "󰂁"
        if (level >= 60) return "󰂀"
        if (level >= 50) return "󰁿"
        if (level >= 40) return "󰁾"
        if (level >= 30) return "󰁽"
        if (level >= 20) return "󰁼"
        if (level >= 10) return "󰁻"
        return "󰁺"
    }
    
    function getVolumeIcon(level: int, muted: bool): string {
        if (muted) return "󰝟"
        if (level >= 66) return "󰕾"
        if (level >= 33) return "󰖀"
        if (level > 0) return "󰕿"
        return "󰝟"
    }
    
    function getWifiIcon(enabled: bool, connected: string): string {
        if (!enabled) return "󰤭"
        if (connected === "") return "󰤯"
        return "󰤨"
    }
    
    function getWifiSignalIcon(signal: int): string {
        if (signal >= 75) return "󰤨"
        if (signal >= 50) return "󰤥"
        if (signal >= 25) return "󰤢"
        return "󰤟"
    }
    
    // ===== TIME HELPERS =====
    function formatTime(microseconds: int): string {
        var seconds = Math.floor(microseconds / 1000000)
        var mins = Math.floor(seconds / 60)
        var secs = seconds % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
    
    function formatUptime(seconds: int): string {
        var days = Math.floor(seconds / 86400)
        var hours = Math.floor((seconds % 86400) / 3600)
        var mins = Math.floor((seconds % 3600) / 60)
        if (days > 0) {
            return days + "d " + hours + "h"
        }
        return hours + "h " + mins + "m uptime"
    }
}
