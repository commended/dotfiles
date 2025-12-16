import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: batteryMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool batteryMenuOpen
    required property int batteryLevel
    required property bool batteryCharging
    required property string powerProfile
    required property bool powerProfilesAvailable
    required property int systemUptime
    
    signal setPowerProfile(string profile)
    
    visible: batteryMenuOpen || batteryCloseAnim.running
    width: 280
    height: powerProfilesAvailable ? 240 : 140
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - width - 1
    anchor.rect.y: barExpanded ? 40 : 15
    anchor.rect.width: width
    anchor.rect.height: height
    
    color: "transparent"
    
    Item {
        anchors.fill: parent
        scale: batteryMenuOpen ? 1.0 : 0.0
        opacity: batteryMenuOpen ? 1.0 : 0.0
        transformOrigin: Item.Top
        
        Behavior on scale {
            NumberAnimation {
                id: batteryCloseAnim
                duration: 200
                easing.type: batteryMenuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: batteryMenuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
    
        Canvas {
            id: batteryBowlCanvas
            anchors.fill: parent
        
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "#1a1a1a"
                
                var radius = 20
                
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width, height - radius)
                ctx.arcTo(width, height, width - radius, height, radius)
                ctx.lineTo(radius, height)
                ctx.arcTo(0, height, 0, height - radius, radius)
                ctx.lineTo(0, 0)
                ctx.closePath()
                ctx.fill()
            }
            
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12
            
            // Battery Status
            Rectangle {
                width: parent.width
                height: 60
                radius: 8
                color: "#2a2a2a"
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    // Battery semi-circle indicator
                    Item {
                        width: 50
                        height: 50
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Canvas {
                            id: batteryArcCanvas
                            anchors.fill: parent
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = 20
                                var startAngle = -Math.PI / 2
                                var fillAngle = startAngle + (2 * Math.PI * (batteryLevel / 100))
                                
                                // Background circle
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
                                ctx.strokeStyle = "#404040"
                                ctx.lineWidth = 3
                                ctx.stroke()
                                
                                // Filled arc based on battery level
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, startAngle, fillAngle, false)
                                ctx.strokeStyle = batteryLevel <= 20 && !batteryCharging ? "#ff6b6b" : "#ffffff"
                                ctx.lineWidth = 3
                                ctx.stroke()
                            }
                        }
                        
                        Text {
                            property string batteryIcon: {
                                if (batteryCharging) return "󰂄"
                                if (batteryLevel >= 90) return "󰁹"
                                if (batteryLevel >= 80) return "󰂂"
                                if (batteryLevel >= 70) return "󰂁"
                                if (batteryLevel >= 60) return "󰂀"
                                if (batteryLevel >= 50) return "󰁿"
                                if (batteryLevel >= 40) return "󰁾"
                                if (batteryLevel >= 30) return "󰁽"
                                if (batteryLevel >= 20) return "󰁼"
                                if (batteryLevel >= 10) return "󰁻"
                                return "󰁺"
                            }
                            anchors.centerIn: parent
                            text: batteryIcon
                            font.pixelSize: 20
                            font.family: "JetBrains Mono Nerd Font"
                            color: batteryLevel <= 20 && !batteryCharging ? "#ff6b6b" : "#ffffff"
                        }
                        
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: batteryArcCanvas.requestPaint()
                        }
                    }
                    
                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: batteryLevel + "%"
                            font.pixelSize: 20
                            font.family: "JetBrains Mono Nerd Font"
                            font.bold: true
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: batteryCharging ? "Charging" : "Discharging"
                            font.pixelSize: 10
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#888888"
                        }
                        
                        Text {
                            function formatUptime(seconds) {
                                var days = Math.floor(seconds / 86400)
                                var hours = Math.floor((seconds % 86400) / 3600)
                                var mins = Math.floor((seconds % 3600) / 60)
                                if (days > 0) {
                                    return days + "d " + hours + "h"
                                }
                                return hours + "h " + mins + "m uptime"
                            }
                            text: formatUptime(systemUptime)
                            font.pixelSize: 9
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#666666"
                        }
                    }
                }
            }
            
            // Power Profile Header
            Text {
                text: powerProfilesAvailable ? "Power Profile" : "Power Profiles Unavailable"
                font.pixelSize: 11
                font.family: "JetBrains Mono Nerd Font"
                font.bold: true
                color: "#888888"
            }
            
            // Info message when unavailable
            Text {
                width: parent.width
                text: "Install and enable power-profiles-daemon"
                font.pixelSize: 10
                font.family: "JetBrains Mono Nerd Font"
                color: "#666666"
                wrapMode: Text.WordWrap
                visible: !powerProfilesAvailable
            }
            
            // Power Profiles
            Column {
                width: parent.width
                spacing: 6
                visible: powerProfilesAvailable
                
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: powerProfile === "performance" ? "#404040" : (perfMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8
                        
                        Text {
                            text: "󱐋"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Performance"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "󰄬"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            visible: powerProfile === "performance"
                        }
                    }
                    
                    MouseArea {
                        id: perfMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            batteryMenuWindow.setPowerProfile("performance")
                        }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: powerProfile === "balanced" ? "#404040" : (balMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8
                        
                        Text {
                            text: "󰾅"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Balanced"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "󰄬"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            visible: powerProfile === "balanced"
                        }
                    }
                    
                    MouseArea {
                        id: balMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            batteryMenuWindow.setPowerProfile("balanced")
                        }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: powerProfile === "power-saver" ? "#404040" : (saverMouseArea.containsMouse ? "#353535" : "#2a2a2a")
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8
                        
                        Text {
                            text: "󰌪"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                        }
                        
                        Text {
                            text: "Power Saver"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "󰄬"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            visible: powerProfile === "power-saver"
                        }
                    }
                    
                    MouseArea {
                        id: saverMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            batteryMenuWindow.setPowerProfile("power-saver")
                        }
                    }
                }
            }
        }
    }
}
