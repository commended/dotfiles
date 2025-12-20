import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: bar
    
    required property bool barExpanded
    required property bool trayCollapsed
    required property bool wifiEnabled
    required property string wifiConnected
    required property bool bluetoothEnabled
    required property int batteryLevel
    required property bool batteryCharging
    required property int volumeLevel
    required property bool volumeMuted
    required property int brightnessLevel
    
    signal toggleBarExpanded()
    signal toggleTrayCollapsed()
    signal openVolumeMenu()
    signal openBluetoothMenu()
    signal openWifiMenu()
    signal openBatteryMenu()
    signal openCalendarMenu()
    signal openBrightnessMenu()
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    height: 72
    
    margins {
        bottom: barExpanded ? 0 : -35
    }
    
    exclusiveZone: barExpanded ? 50 : 5
    
    color: "transparent"
    
    Behavior on margins.bottom {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }
    
    Item {
        anchors.fill: parent
        
        Rectangle {
            id: mainBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            
            height: barExpanded ? 40 : 15
            color: "#1a1a1a"
            radius: 0
            
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 12
                color: "#1a1a1a"
                radius: 12
                visible: barExpanded
            }
            
            MouseArea {
                anchors.fill: parent
                enabled: !barExpanded
                onClicked: bar.toggleBarExpanded()
            }

            
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12
                opacity: barExpanded ? 1.0 : 0.0
                visible: barExpanded
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }
                
                // Workspaces
                Row {
                    spacing: 6
                    
                    Repeater {
                        model: 5
                        
                        Rectangle {
                            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
                            property bool hasWindows: {
                                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                                    if (Hyprland.workspaces.values[i].id === (index + 1)) {
                                        return true;
                                    }
                                }
                                return false;
                            }
                            
                            width: 32
                            height: 24
                            radius: 6
                            color: isActive ? "#ffffff" : (hasWindows ? "#404040" : "#2a2a2a")
                            
                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                font.pixelSize: 12
                                font.bold: parent.isActive
                                color: parent.isActive ? "#1a1a1a" : "#ffffff"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: barExpanded
                                onClicked: {
                                    Hyprland.dispatch("workspace " + (index + 1))
                                }
                            }
                        }
                    }
                }
                
                // Spacer
                Item {
                    Layout.fillWidth: true
                }
            }
            
            // Tray Container
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 8
                spacing: 0
                opacity: barExpanded ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }
                
                // Collapse Arrow
                Rectangle {
                    width: 24
                    height: 24
                    radius: 6
                    color: trayArrowArea.containsMouse ? "#404040" : "#2a2a2a"
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 1.0
                    
                    Text {
                        anchors.centerIn: parent
                        text: trayCollapsed ? "<" : ">"
                        font.pixelSize: 12
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: trayArrowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.toggleTrayCollapsed()
                    }
                }
                
                // Tray Bubble
                Rectangle {
                    width: trayCollapsed ? 0 : trayRow.width + 20
                    height: 24
                    radius: 6
                    color: "#2a2a2a"
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    Row {
                        id: trayRow
                        anchors.centerIn: parent
                        spacing: 12
                        opacity: trayCollapsed ? 0.0 : 1.0
                        
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        // WiFi
                        Text {
                            property string wifiIcon: {
                                if (!wifiEnabled) return "󰤭"
                                if (wifiConnected === "") return "󰤯"
                                return "󰤨"
                            }
                            text: wifiIcon
                            font.pixelSize: 16
                            font.family: "JetBrains Mono Nerd Font"
                            color: wifiEnabled ? "#ffffff" : "#888888"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openWifiMenu()
                            }
                        }
                        
                        // Bluetooth
                        Text {
                            text: "󰂯"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openBluetoothMenu()
                            }
                        }
                        
                        // Battery
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
                            text: batteryIcon + " " + batteryLevel + "%"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: batteryLevel <= 20 && !batteryCharging ? "#ff6b6b" : "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openBatteryMenu()
                            }
                        }
                        
                        // Volume
                        Text {
                            property string volIcon: {
                                if (volumeMuted) return "󰝟"
                                if (volumeLevel >= 66) return "󰕾"
                                if (volumeLevel >= 33) return "󰖀"
                                if (volumeLevel > 0) return "󰕿"
                                return "󰝟"
                            }
                            text: volIcon + " " + volumeLevel + "%"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: volumeMuted ? "#888888" : "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openVolumeMenu()
                            }
                        }
                        
                        // Brightness
                        Text {
                            text: "󰃠 " + brightnessLevel + "%"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openBrightnessMenu()
                            }
                        }
                    }
                }
            }
            
            // Clock - positioned absolutely in center
            Text {
                id: clock
                anchors.centerIn: parent
                font.pixelSize: 16
                font.family: "JetBrains Mono Nerd Font"
                color: "#ffffff"
                z: 100
                opacity: barExpanded ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        clock.text = Qt.formatDateTime(new Date(), "hh:mm")
                    }
                    Component.onCompleted: triggered()
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!barExpanded) return
                        bar.openCalendarMenu()
                    }
                }
            }
        }
        
        // Right corner arch connector
        Item {
            anchors {
                top: mainBar.bottom
                right: parent.right
            }
            width: 60
            height: barExpanded ? 100 : 60
            
            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
            
            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = "#1a1a1a"
                    ctx.beginPath()
                    
                    // Start at bottom-right corner
                    ctx.moveTo(width, height)
                    // Line to top-right
                    ctx.lineTo(width, 0)
                    // Line to top-left
                    ctx.lineTo(0, 0)
                    // Arc from top-left back to bottom-right with slightly larger radius for smoother curve
                    var radius = width * 1.2
                    ctx.arcTo(width, 0, width, height, radius)
                    // Continue line down to bottom
                    ctx.lineTo(width, height)
                    ctx.closePath()
                    ctx.fill()
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }
        }
        
        // Hover detection area for toggle button
        MouseArea {
            id: toggleHoverArea
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: mainBar.bottom
            }
            width: 60
            height: 5
            hoverEnabled: true
            z: 300
        }
        
        // Toggle Button
        Item {
            id: toggleButton
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: mainBar.bottom
            }
            
            width: 60
            height: (toggleMouseArea.containsMouse || toggleHoverArea.containsMouse) ? 32 : 20
            clip: true
            opacity: (!barExpanded || toggleMouseArea.containsMouse || toggleHoverArea.containsMouse) ? 1.0 : 0.0
            z: 300
            
            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            
            Canvas {
                id: curvedTop
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: 20
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = "#1a1a1a"
                    
                    ctx.beginPath()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.quadraticCurveTo(width, height, width - 15, height)
                    ctx.lineTo(15, height)
                    ctx.quadraticCurveTo(0, height, 0, 0)
                    ctx.closePath()
                    ctx.fill()
                }
            }
            
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -4
                text: barExpanded ? "▲" : "▼"
                font.pixelSize: 14
                color: "#ffffff"
                opacity: (toggleMouseArea.containsMouse || toggleHoverArea.containsMouse) ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            MouseArea {
                id: toggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: bar.toggleBarExpanded()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
