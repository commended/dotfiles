import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PopupWindow {
    id: wifiMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property bool wifiEnabled
    required property string wifiConnected
    required property var wifiNetworks
    
    signal toggleWifi(bool enable)
    signal connectNetwork(string ssid)
    signal disconnectNetwork()
    
    visible: menuOpen || wifiCloseAnim.running
    width: 320
    height: 400
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - 415
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
                id: wifiCloseAnim
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
            id: wifiBowlCanvas
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
            id: wifiContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.marginMedium
            spacing: Theme.marginDefault
            
            // WiFi Toggle
            Rectangle {
                width: parent.width
                height: 44
                radius: Theme.radiusMedium
                color: Theme.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.marginDefault
                    
                    Text {
                        text: "󰤨  WiFi"
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    ToggleSwitch {
                        switchWidth: 44
                        switchHeight: 24
                        checked: wifiEnabled
                        onToggled: (value) => wifiMenuWindow.toggleWifi(value)
                    }
                }
            }
            
            // Connected network
            Rectangle {
                width: parent.width
                height: wifiConnected !== "" ? 30 : 0
                radius: Theme.spacingSmall
                color: Theme.surfaceHover
                visible: wifiConnected !== ""
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: Theme.spacingMedium
                    
                    Text {
                        text: "󰤨"
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    
                    Text {
                        text: wifiConnected
                        font.pixelSize: Theme.fontSizeDefault
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Disconnect"
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        color: Theme.textDanger
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiMenuWindow.disconnectNetwork()
                        }
                    }
                }
            }
            
            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.separator
                visible: wifiEnabled && wifiNetworks.length > 0
            }
            
            // Network list
            ListView {
                id: wifiListView
                width: parent.width
                height: 200
                model: wifiNetworks
                spacing: Theme.radiusSmall
                interactive: true
                clip: true
                visible: wifiEnabled
                
                delegate: Rectangle {
                    width: wifiListView.width
                    height: 36
                    radius: Theme.radiusSmall
                    color: wifiNetMouseArea.containsMouse ? Theme.surfaceActive : Theme.surface
                    visible: !modelData.connected
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: Theme.spacingMedium
                        
                        Text {
                            text: Theme.getWifiSignalIcon(modelData.signal)
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: Theme.fontFamily
                            color: Theme.textSecondary
                        }
                        
                        Text {
                            text: modelData.ssid
                            font.pixelSize: Theme.fontSizeDefault
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.security !== "" ? "󰌾" : ""
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: Theme.fontFamily
                            color: Theme.textSecondary
                        }
                    }
                    
                    MouseArea {
                        id: wifiNetMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiMenuWindow.connectNetwork(modelData.ssid)
                    }
                }
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: wifiEnabled ? "No networks found" : "WiFi disabled"
                font.pixelSize: Theme.fontSizeDefault
                font.family: Theme.fontFamily
                color: Theme.textSecondary
                visible: !wifiEnabled || wifiNetworks.length === 0
            }
        }
    }
}
