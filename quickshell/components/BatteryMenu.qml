import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PopupWindow {
    id: batteryMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property int batteryLevel
    required property bool batteryCharging
    required property string powerProfile
    required property bool powerProfilesAvailable
    required property int systemUptime
    
    signal setProfile(string profile)
    
    visible: menuOpen || batteryCloseAnim.running
    width: 280
    height: powerProfilesAvailable ? 240 : 140
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - width - 15
    anchor.rect.y: barExpanded ? 40 : 15
    anchor.rect.width: width
    anchor.rect.height: height
    
    color: "transparent"
    
    Item {
        anchors.fill: parent
        scale: menuOpen ? 1.0 : 0.0
        opacity: menuOpen ? 1.0 : 0.0
        transformOrigin: Item.Top
        
        Behavior on scale {
            NumberAnimation {
                id: batteryCloseAnim
                duration: Theme.animationDurationNormal
                easing.type: menuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animationDurationFast
                easing.type: menuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
    
        Canvas {
            id: batteryBowlCanvas
            anchors.fill: parent
        
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.background
                
                var radius = Theme.radiusFull
                
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width, height)
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
            anchors.margins: Theme.marginLarge
            spacing: Theme.spacingLarge
            
            // Battery Status
            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.radiusMedium
                color: Theme.surface
                
                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.marginDefault
                    spacing: Theme.marginDefault
                    
                    // Battery circle indicator
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
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
                                ctx.strokeStyle = Theme.surfaceHover
                                ctx.lineWidth = 3
                                ctx.stroke()
                                
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, startAngle, fillAngle, false)
                                ctx.strokeStyle = batteryLevel <= 20 && !batteryCharging ? Theme.textDanger : Theme.accent
                                ctx.lineWidth = 3
                                ctx.stroke()
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: Theme.getBatteryIcon(batteryLevel, batteryCharging)
                            font.pixelSize: Theme.fontSizeXLarge
                            font.family: Theme.fontFamily
                            color: batteryLevel <= 20 && !batteryCharging ? Theme.textDanger : Theme.textPrimary
                        }
                        
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: batteryArcCanvas.requestPaint()
                        }
                    }
                    
                    Column {
                        spacing: Theme.spacingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: batteryLevel + "%"
                            font.pixelSize: Theme.fontSizeXLarge
                            font.family: Theme.fontFamily
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        
                        Text {
                            text: batteryCharging ? "Charging" : "Discharging"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: Theme.fontFamily
                            color: Theme.textSecondary
                        }
                        
                        Text {
                            text: Theme.formatUptime(systemUptime)
                            font.pixelSize: 9
                            font.family: Theme.fontFamily
                            color: Theme.textDisabled
                        }
                    }
                }
            }
            
            // Power Profile Header
            Text {
                text: powerProfilesAvailable ? "Power Profile" : "Power Profiles Unavailable"
                font.pixelSize: 11
                font.family: Theme.fontFamily
                font.bold: true
                color: Theme.textSecondary
            }
            
            // Info message when unavailable
            Text {
                width: parent.width
                text: "Install and enable power-profiles-daemon"
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                color: Theme.textDisabled
                wrapMode: Text.WordWrap
                visible: !powerProfilesAvailable
            }
            
            // Power Profiles
            Column {
                width: parent.width
                spacing: Theme.radiusSmall
                visible: powerProfilesAvailable
                
                Repeater {
                    model: [
                        { id: "performance", icon: "󱐋", label: "Performance" },
                        { id: "balanced", icon: "󰾅", label: "Balanced" },
                        { id: "power-saver", icon: "󰌪", label: "Power Saver" }
                    ]
                    
                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: Theme.radiusSmall
                        color: powerProfile === modelData.id ? Theme.surfaceHover : 
                               (profileMouseArea.containsMouse ? Theme.surfaceSubtle : Theme.surface)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.radiusSmall
                            spacing: Theme.spacingMedium
                            
                            Text {
                                text: modelData.icon
                                font.pixelSize: Theme.fontSizeMedium
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                            }
                            
                            Text {
                                text: modelData.label
                                font.pixelSize: Theme.fontSizeDefault
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: "�"
                                font.pixelSize: Theme.fontSizeDefault
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                                visible: powerProfile === modelData.id
                            }
                        }
                        
                        MouseArea {
                            id: profileMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: batteryMenuWindow.setProfile(modelData.id)
                        }
                    }
                }
            }
        }
    }
}
