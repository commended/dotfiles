import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: notificationWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool notifVisible
    required property string notificationType
    required property int value
    required property string bluetoothDeviceName
    required property bool bluetoothConnected
    
    visible: notifVisible || notifCloseAnim.running
    width: 240
    height: 70
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - width
    anchor.rect.y: barExpanded ? 40 : 15
    anchor.rect.width: width
    anchor.rect.height: height
    
    color: "transparent"
    
    Item {
        anchors.fill: parent
        scale: notifVisible ? 1.0 : 0.95
        opacity: notifVisible ? 1.0 : 0.0
        
        Behavior on scale {
            NumberAnimation {
                id: notifCloseAnim
                duration: 200
                easing.type: notifVisible ? Easing.OutBack : Easing.InCubic
            }
        }
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: notifVisible ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Canvas {
            id: mainCard
            anchors.fill: parent
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "#1a1a1a"
                
                var radius = 20
                
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
        
        Item {
            anchors.fill: parent
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                
                Rectangle {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46
                    Layout.alignment: Qt.AlignVCenter
                    radius: 8
                    color: "#2a2a2a"
                    
                    Text {
                        property string icon: {
                            if (notificationType === "volume") {
                                if (value >= 66) return "󰕾"
                                if (value >= 33) return "󰖀"
                                return "󰕿"
                            } else if (notificationType === "brightness") {
                                return "󰃠"
                            } else if (notificationType === "bluetooth") {
                                return bluetoothConnected ? "󰂱" : "󰂲"
                            }
                            return ""
                        }
                        anchors.centerIn: parent
                        text: icon
                        font.pixelSize: 26
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                }
                
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4
                    
                    Text {
                        property string title: {
                            if (notificationType === "volume") return "Volume"
                            if (notificationType === "brightness") return "Brightness"
                            if (notificationType === "bluetooth") {
                                return bluetoothConnected ? "Connected" : "Disconnected"
                            }
                            return ""
                        }
                        text: title
                        font.pixelSize: 13
                        font.family: "JetBrains Mono Nerd Font"
                        font.bold: true
                        color: "#ffffff"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    
                    Text {
                        text: {
                            if (notificationType === "volume" || notificationType === "brightness") {
                                return value + "%"
                            }
                            if (notificationType === "bluetooth") {
                                return bluetoothDeviceName
                            }
                            return ""
                        }
                        font.pixelSize: 11
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#888888"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 3
                        radius: 1.5
                        color: "#2a2a2a"
                        visible: notificationType === "volume" || notificationType === "brightness"
                        
                        Rectangle {
                            width: (value / 100) * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: "#ffffff"
                            
                            Behavior on width {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
