import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: wifiMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool wifiMenuOpen
    required property bool wifiEnabled
    required property string wifiConnected
    required property var wifiNetworks
    
    signal toggleWifi(bool enabling)
    signal connectNetwork(string ssid)
    signal disconnectNetwork()
    
    visible: wifiMenuOpen || wifiCloseAnim.running
    width: 320
    height: 400
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - 380
    anchor.rect.y: barExpanded ? 40 : 15
    anchor.rect.width: width
    anchor.rect.height: height
    
    color: "transparent"
    
    Item {
        anchors.fill: parent
        scale: wifiMenuOpen ? 1.0 : 0.0
        opacity: wifiMenuOpen ? 1.0 : 0.0
        transformOrigin: Item.Top
        
        Behavior on scale {
            NumberAnimation {
                id: wifiCloseAnim
                duration: 200
                easing.type: wifiMenuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: wifiMenuOpen ? Easing.OutCubic : Easing.InCubic
            }
        }
    
        Canvas {
            id: wifiBowlCanvas
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
        id: wifiContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10
        
        // WiFi Toggle
        Rectangle {
            width: parent.width
            height: 44
            radius: 8
            color: "#2a2a2a"
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                Text {
                    text: "󰤨  WiFi"
                    font.pixelSize: 16
                    font.family: "JetBrains Mono Nerd Font"
                    color: "#ffffff"
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: wifiEnabled ? "#ffffff" : "#404040"
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: wifiEnabled ? "#1a1a1a" : "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                        x: wifiEnabled ? parent.width - width - 2 : 2
                        
                        Behavior on x {
                            NumberAnimation { duration: 150 }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiMenuWindow.toggleWifi(!wifiEnabled)
                        }
                    }
                }
            }
        }
        
        // Connected network
        Rectangle {
            width: parent.width
            height: wifiConnected !== "" ? 30 : 0
            radius: 4
            color: "#404040"
            visible: wifiConnected !== ""
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 8
                
                Text {
                    text: "󰤨"
                    font.pixelSize: 14
                    font.family: "JetBrains Mono Nerd Font"
                    color: "#ffffff"
                }
                
                Text {
                    text: wifiConnected
                    font.pixelSize: 12
                    font.family: "JetBrains Mono Nerd Font"
                    color: "#ffffff"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "Disconnect"
                    font.pixelSize: 10
                    font.family: "JetBrains Mono Nerd Font"
                    color: "#ff6b6b"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiMenuWindow.disconnectNetwork()
                        }
                    }
                }
            }
        }
        
        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: "#404040"
            visible: wifiEnabled && wifiNetworks.length > 0
        }
        
        // Network list
        ListView {
            id: wifiListView
            width: parent.width
            height: 200
            model: wifiNetworks
            spacing: 6
            interactive: true
            clip: true
            visible: wifiEnabled
            
            delegate: Rectangle {
                width: wifiListView.width
                height: 36
                radius: 6
                color: wifiNetMouseArea.containsMouse ? "#505050" : "#2a2a2a"
                visible: !modelData.connected
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8
                    
                    Text {
                        property string signalIcon: {
                            if (modelData.signal >= 75) return "󰤨"
                            if (modelData.signal >= 50) return "󰤥"
                            if (modelData.signal >= 25) return "󰤢"
                            return "󰤟"
                        }
                        text: signalIcon
                        font.pixelSize: 14
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#888888"
                    }
                    
                    Text {
                        text: modelData.ssid
                        font.pixelSize: 12
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: modelData.security !== "" ? "󰌾" : ""
                        font.pixelSize: 10
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#888888"
                    }
                }
                
                MouseArea {
                    id: wifiNetMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wifiMenuWindow.connectNetwork(modelData.ssid)
                    }
                }
            }
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: wifiEnabled ? "No networks found" : "WiFi disabled"
            font.pixelSize: 12
            font.family: "JetBrains Mono Nerd Font"
            color: "#888888"
            visible: !wifiEnabled || wifiNetworks.length === 0
        }
    }
    }
}
