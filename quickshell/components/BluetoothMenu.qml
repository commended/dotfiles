import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

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
    anchor.rect.x: barWindow.width - 335
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
            id: btBowlShape
            anchors.fill: parent
        
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.background
                
                var radius = Theme.radiusFull
                
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
            anchors.margins: Theme.marginDefault
            spacing: Theme.spacingMedium
            
            // Bluetooth Toggle
            Rectangle {
                width: parent.width
                height: 40
                radius: Theme.radiusMedium
                color: Theme.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMedium
                    
                    Text {
                        text: "󰂯  Bluetooth"
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    ToggleSwitch {
                        checked: bluetoothEnabled
                        onToggled: (value) => bluetoothMenuWindow.toggleBluetooth(value)
                    }
                }
            }
            
            // Connection Status
            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.radiusSmall
                color: Theme.surface
                
                Text {
                    anchors.centerIn: parent
                    property bool anyConnected: {
                        for (var i = 0; i < bluetoothDevices.length; i++) {
                            if (bluetoothDevices[i].connected) return true
                        }
                        return false
                    }
                    text: bluetoothEnabled ? (anyConnected ? "󰂱 Connected" : "󰂲 Disconnected") : "󰂲 Bluetooth Off"
                    font.pixelSize: Theme.fontSizeDefault
                    font.family: Theme.fontFamily
                    color: anyConnected ? Theme.textPrimary : Theme.textSecondary
                }
            }
            
            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.separator
                visible: bluetoothEnabled && bluetoothDevices.length > 0
            }
            
            Repeater {
                model: bluetoothDevices
                
                Rectangle {
                    width: btDevicesList.width
                    height: 36
                    radius: Theme.spacingSmall
                    color: btDeviceMouseArea.containsMouse ? Theme.surfaceActive : (modelData.connected ? Theme.surfaceHover : Theme.surface)
                    visible: bluetoothEnabled
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: Theme.spacingMedium
                        
                        Text {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeDefault
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: modelData.connected ? "󰂱" : "󰂯"
                            font.pixelSize: Theme.fontSizeDefault
                            font.family: Theme.fontFamily
                            color: modelData.connected ? Theme.textPrimary : Theme.textSecondary
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
                font.pixelSize: Theme.fontSizeDefault
                font.family: Theme.fontFamily
                color: Theme.textSecondary
                visible: !bluetoothEnabled || bluetoothDevices.length === 0
            }
        }
    }
}
