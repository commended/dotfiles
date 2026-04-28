import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

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
    
    exclusiveZone: barExpanded ? 50: 15
    
    color: "transparent"
    
    Behavior on margins.bottom {
        NumberAnimation {
            duration: Theme.animationDurationSlow
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
            color: Theme.background
            
            Behavior on height {
                NumberAnimation {
                    duration: Theme.animationDurationSlow
                    easing.type: Easing.InOutCubic
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.radiusLarge
                color: Theme.background
                radius: Theme.radiusLarge
                visible: barExpanded
            }
            
            MouseArea {
                anchors.fill: parent
                enabled: !barExpanded
                onClicked: bar.toggleBarExpanded()
            }

            
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingMedium
                spacing: Theme.spacingLarge
                opacity: barExpanded ? 1.0 : 0.0
                visible: barExpanded
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
                
                // Workspaces
                Row {
                    spacing: Theme.radiusSmall
                    
                    Repeater {
                        model: 5
                        
                        Rectangle {
                            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
                            property bool hasWindows: {
                                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                                    if (Hyprland.workspaces.values[i].id === (index + 1)) {
                                        return true
                                    }
                                }
                                return false
                            }
                            
                            width: 32
                            height: 24
                            radius: Theme.radiusSmall
                            color: isActive ? Theme.accent : (hasWindows ? Theme.surfaceHover : Theme.surface)
                            
                            Text {
                                anchors.centerIn: parent
                                text: index + 1
                                font.pixelSize: Theme.fontSizeDefault
                                font.bold: parent.isActive
                                font.family: Theme.fontFamily
                                color: parent.isActive ? Theme.accentText : Theme.textPrimary
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: barExpanded
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                    
                    // Overflow workspaces > 5 (show each one that has windows)
                    Repeater {
                        model: {
                            var overflowWorkspaces = []
                            for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                                var wsId = Hyprland.workspaces.values[i].id
                                if (wsId > 5) {
                                    overflowWorkspaces.push(wsId)
                                }
                            }
                            overflowWorkspaces.sort(function(a, b) { return a - b })
                            return overflowWorkspaces
                        }
                        
                        Rectangle {
                            property int workspaceId: modelData
                            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === workspaceId
                            
                            width: 32
                            height: 24
                            radius: Theme.radiusSmall
                            color: isActive ? Theme.accent : Theme.surfaceHover
                            
                            Text {
                                anchors.centerIn: parent
                                text: parent.workspaceId
                                font.pixelSize: Theme.fontSizeDefault
                                font.bold: parent.isActive
                                font.family: Theme.fontFamily
                                color: parent.isActive ? Theme.accentText : Theme.textPrimary
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: barExpanded
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + parent.workspaceId)
                            }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // Tray Container
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: Theme.spacingMedium
                spacing: 0
                opacity: barExpanded ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
                
                // Collapse Arrow
                Rectangle {
                    width: 24
                    height: 24
                    radius: Theme.radiusSmall
                    color: trayArrowArea.containsMouse ? Theme.surfaceHover : Theme.surface
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        anchors.centerIn: parent
                        text: trayCollapsed ? "<" : ">"
                        font.pixelSize: Theme.fontSizeDefault
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
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
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.animationDurationNormal
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    Row {
                        id: trayRow
                        anchors.centerIn: parent
                        spacing: Theme.spacingLarge
                        opacity: trayCollapsed ? 0.0 : 1.0
                        
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animationDurationFast
                                easing.type: Easing.InOutQuad
                            }
                        }
                        
                        // WiFi
                        Text {
                            text: Theme.getWifiIcon(wifiEnabled, wifiConnected)
                            font.pixelSize: Theme.fontSizeLarge
                            font.family: Theme.fontFamily
                            color: wifiEnabled ? Theme.textPrimary : Theme.textSecondary
                            
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
                            font.pixelSize: Theme.fontSizeLarge
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openBluetoothMenu()
                            }
                        }
                        
                        // Battery
                        Text {
                            text: Theme.getBatteryIcon(batteryLevel, batteryCharging) + " " + batteryLevel + "%"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: Theme.fontFamily
                            color: batteryLevel <= 20 && !batteryCharging ? Theme.textDanger : Theme.textPrimary
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: barExpanded
                                onClicked: bar.openBatteryMenu()
                            }
                        }
                        
                        // Volume
                        Text {
                            text: Theme.getVolumeIcon(volumeLevel, volumeMuted) + " " + volumeLevel + "%"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: Theme.fontFamily
                            color: volumeMuted ? Theme.textSecondary : Theme.textPrimary
                            
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
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                            
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
                font.pixelSize: Theme.fontSizeLarge
                font.family: Theme.fontFamily
                color: Theme.textPrimary
                z: 100
                opacity: barExpanded ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationDurationSlow
                        easing.type: Easing.InOutCubic
                    }
                }
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm")
                    Component.onCompleted: triggered()
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (barExpanded) bar.openCalendarMenu()
                    }
                }
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
                    duration: Theme.animationDurationNormal
                    easing.type: Easing.InOutQuad
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animationDurationNormal
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
                    ctx.fillStyle = Theme.background
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
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textPrimary
                opacity: (toggleMouseArea.containsMouse || toggleHoverArea.containsMouse) ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animationDurationNormal
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            MouseArea {
                id: toggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: bar.toggleBarExpanded()
            }
        }
    }
}
