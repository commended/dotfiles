import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: bluetoothMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property var bluetoothDevices
    required property bool bluetoothEnabled
    
    signal toggleBluetooth(bool enable)
    signal connectDevice(string mac)
    signal disconnectDevice(string mac)
    
    visible: menuOpen || btCloseAnim.running
    width: 280
    height: 250
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - 300
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
                id: btCloseAnim
                duration: 200
                easing.type: menuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: menuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
    
        Canvas {
            id: btBowlShape
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
            id: btDevicesList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 8
            
            // Bluetooth Toggle
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: "#2a2a2a"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        text: "󰂯  Bluetooth"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 40
                        height: 22
                        radius: 11
                        color: bluetoothEnabled ? "#ffffff" : "#404040"
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: bluetoothEnabled ? "#1a1a1a" : "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                            x: bluetoothEnabled ? parent.width - width - 2 : 2
                            
                            Behavior on x {
                                NumberAnimation { duration: 150 }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                bluetoothMenuWindow.toggleBluetooth(!bluetoothEnabled)
                            }
                        }
                    }
                }
            }
            
            // Connection Status
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: "#2a2a2a"
                
                Text {
                    anchors.centerIn: parent
                    property bool anyConnected: {
                        for (var i = 0; i < bluetoothDevices.length; i++) {
                            if (bluetoothDevices[i].connected) return true
                        }
                        return false
                    }
                    text: bluetoothEnabled ? (anyConnected ? "󰂱 Connected" : "󰂲 Disconnected") : "󰂲 Bluetooth Off"
                    font.pixelSize: 12
                    font.family: "JetBrains Mono Nerd Font"
                    color: anyConnected ? "#ffffff" : "#888888"
                }
            }
            
            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: "#404040"
                visible: bluetoothEnabled && bluetoothDevices.length > 0
            }
            
            Repeater {
                model: bluetoothDevices
                
                Rectangle {
                    width: btDevicesList.width
                    height: 36
                    radius: 4
                    color: btDeviceMouseArea.containsMouse ? "#505050" : (modelData.connected ? "#404040" : "#2a2a2a")
                    visible: bluetoothEnabled
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 8
                        
                        Text {
                            text: modelData.name
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: modelData.connected ? "#ffffff" : "#ffffff"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: modelData.connected ? "󰂱" : "󰂯"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: modelData.connected ? "#ffffff" : "#888888"
                        }
                    }
                    
                    MouseArea {
                        id: btDeviceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected) {
                                bluetoothMenuWindow.disconnectDevice(modelData.mac)
                            } else {
                                bluetoothMenuWindow.connectDevice(modelData.mac)
                            }
                        }
                    }
                }
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: bluetoothEnabled ? "No devices found" : "Bluetooth disabled"
                font.pixelSize: 12
                font.family: "JetBrains Mono Nerd Font"
                color: "#888888"
                visible: !bluetoothEnabled || bluetoothDevices.length === 0
            }
        }
    }
}
