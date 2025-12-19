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
    
    width: 15
    
    exclusiveZone: 15
    
    color: "transparent"
    
    // Main vertical bar
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
    }
    
    // Curved connector - semi-circle arch
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
