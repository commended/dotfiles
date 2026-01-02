import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PanelWindow {
    id: rightBar
    
    required property bool barExpanded
    required property bool rightBarExpanded
    required property bool rightTrayCollapsed
    
    signal toggleRightBar()
    signal toggleRightTrayCollapsed()
    
    anchors {
        top: true
        right: true
        bottom: true
    }
    
    margins {
        top: barExpanded ? 0 : 15
    }
    
    Behavior on margins.top {
        NumberAnimation {
            duration: Theme.animationDurationSlow
            easing.type: Easing.InOutCubic
        }
    }
    
    width: 15
    exclusiveZone: 15
    color: "transparent"
    
    // Main vertical bar
    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: 15
        color: Theme.background
        
        Canvas {
            id: topCornerRadius
            anchors {
                top: parent.top
                right: parent.right
            }
            width: 15
            height: 15
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.background
                var radius = Theme.radiusLarge
                
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(width - radius, 0)
                ctx.arcTo(width, 0, width, radius, radius)
                ctx.lineTo(width, height)
                ctx.lineTo(0, height)
                ctx.closePath()
                ctx.fill()
            }
            
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
        
        // Right Tray Container
        Column {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: Theme.marginDefault
            }
            spacing: 0
            
            // Collapse Arrow Bubble
            Rectangle {
                width: 36
                height: 36
                radius: Theme.radiusRound
                color: trayArrowArea.containsMouse ? Theme.surfaceHover : Theme.surface
                anchors.horizontalCenter: parent.horizontalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: rightTrayCollapsed ? "󰅃" : "󰅀"
                    font.pixelSize: Theme.fontSizeMedium
                    font.family: Theme.fontFamily
                    color: Theme.textPrimary
                }
                
                MouseArea {
                    id: trayArrowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: rightBar.toggleRightTrayCollapsed()
                }
            }
            
            // Spacer
            Item {
                width: 1
                height: rightTrayCollapsed ? 0 : Theme.spacingMedium
                
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
            }
            
            // Tray items bubble
            Rectangle {
                width: 36
                height: rightTrayCollapsed ? 0 : 44
                radius: Theme.radiusRound
                color: Theme.surface
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                opacity: rightTrayCollapsed ? 0 : 1
                visible: !rightTrayCollapsed || trayOpacityAnim.running
                
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        id: trayOpacityAnim
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
                
                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingMedium
                    
                    // Power button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: powerBtnMouseArea.containsMouse ? Theme.surfaceActive : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰐥"
                            font.pixelSize: Theme.fontSizeLarge
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        
                        MouseArea {
                            id: powerBtnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: rightBar.toggleRightBar()
                        }
                    }
                }
            }
        }
    }
    
    // Top arch connector
    Item {
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 15
        }
        x: -80
        width: 80
        height: barExpanded ? 40 : 15
        z: 10
        
        Behavior on height {
            NumberAnimation {
                duration: Theme.animationDurationSlow
                easing.type: Easing.InOutCubic
            }
        }
        
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.background
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(width, 0)
                ctx.lineTo(width, height)
                var bulge = barExpanded ? 35 : 25
                ctx.quadraticCurveTo(width - bulge, height / 2, 0, 0)
                ctx.closePath()
                ctx.fill()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }
}
