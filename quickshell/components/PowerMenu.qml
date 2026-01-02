import QtQuick
import Quickshell
import ".."

PanelWindow {
    id: powerMenu
    
    required property var barWindow
    required property bool menuOpen
    
    signal lockClicked()
    signal restartClicked()
    signal powerClicked()
    
    visible: menuOpen || slideAnim.running
    
    anchors {
        bottom: true
        right: true
    }
    
    margins {
        right: menuOpen ? 0 : -175
        bottom: 0
    }
    
    Behavior on margins.right {
        NumberAnimation {
            id: slideAnim
            duration: Theme.animationDurationSlow
            easing.type: Easing.InOutCubic
        }
    }
    
    width: 175
    height: 50
    
    color: "transparent"
    
    // Background with only top-left corner rounded
    Item {
        anchors.fill: parent
        
        // Main background
        Rectangle {
            id: bgMain
            anchors.fill: parent
            anchors.topMargin: Theme.radiusFull
            color: Theme.background
        }
        
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: Theme.radiusFull
            anchors.top: parent.top
            anchors.right: parent.right
            height: Theme.radiusFull
            color: Theme.background
        }
        
        // Top-left rounded corner
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: Theme.radiusFull * 2
            height: Theme.radiusFull * 2
            radius: Theme.radiusFull
            color: Theme.background
        }
    }
    
    // Action buttons
    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingMedium
        opacity: menuOpen ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animationDurationFast }
        }
        
        // Lock
        Rectangle {
            width: 40
            height: 40
            radius: width / 2
            color: lockArea.containsMouse ? Theme.surfaceHover : Theme.surface
            
            Text {
                anchors.centerIn: parent
                text: "󰌾"
                font.pixelSize: Theme.fontSizeIcon
                font.family: Theme.fontFamily
                color: Theme.textPrimary
            }
            
            MouseArea {
                id: lockArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: powerMenu.lockClicked()
            }
        }
        
        // Restart
        Rectangle {
            width: 40
            height: 40
            radius: width / 2
            color: restartArea.containsMouse ? Theme.surfaceHover : Theme.surface
            
            Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.pixelSize: Theme.fontSizeIcon
                font.family: Theme.fontFamily
                color: Theme.textPrimary
            }
            
            MouseArea {
                id: restartArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: powerMenu.restartClicked()
            }
        }
        
        // Power Off
        Rectangle {
            width: 40
            height: 40
            radius: width / 2
            color: powerArea.containsMouse ? Theme.surfaceActive : Theme.surfaceHover
            
            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.pixelSize: Theme.fontSizeIcon
                font.family: Theme.fontFamily
                color: Theme.textDanger
            }
            
            MouseArea {
                id: powerArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: powerMenu.powerClicked()
            }
        }
    }
}
