import QtQuick
import Quickshell

PanelWindow {
    id: rightBar
    
    required property bool barExpanded
    
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
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }
    
    width: 15
    
    exclusiveZone: 25
    
    color: "transparent"
    
    Behavior on margins.top {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }
    
    // Main vertical bar
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
    }
    
    // Top arch connector - creates bulging curve at the corner
    Item {
        x: -80
        y: 0
        width: 80
        height: barExpanded ? 40 : 15
        z: 10
        
        Behavior on height {
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
                
                // Start at top-left (connects to top bar)
                ctx.moveTo(0, 0)
                // Line to top-right
                ctx.lineTo(width, 0)
                // Line down to bottom-right (connects to right bar)
                ctx.lineTo(width, height)
                // Curved bulge back to start point
                var bulge = barExpanded ? 35 : 25
                ctx.quadraticCurveTo(width - bulge, height / 2, 0, 0)
                ctx.closePath()
                ctx.fill()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }
    
    // Curved connector - semi-circle arch (existing bottom connector)
    Item {
        anchors {
            top: parent.top
            right: parent.left
        }
        width: 80
        height: barExpanded ? 80 : 40
        
        Behavior on height {
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
                ctx.arc(width + 15, height/2, height/2 + 15, Math.PI/2, 3*Math.PI/2, false)
                ctx.lineTo(width, height)
                ctx.lineTo(width, 0)
                ctx.fill()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }
    }
}
