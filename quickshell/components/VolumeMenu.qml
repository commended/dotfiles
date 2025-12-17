import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: volumeMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property int volumeLevel
    required property int targetVolumeLevel
    required property bool volumeMuted
    required property bool isDraggingVolume
    required property string mediaTitle
    required property string mediaArtist
    required property string mediaThumbnail
    required property bool mediaPlaying
    required property int mediaLength
    required property int mediaPosition
    
    signal volumeChanged(int level)
    signal volumeDragStarted()
    signal volumeDragEnded(int level)
    signal mediaControl(string action)
    
    visible: menuOpen || volCloseAnim.running
    width: 280
    height: mediaTitle !== "" ? 280 : 120
    
    anchor.window: barWindow
    anchor.rect.x: barWindow.width - width - 1
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
                id: volCloseAnim
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
            id: volBowlCanvas
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
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12
            
            // Media Player Section
            Rectangle {
                width: parent.width
                height: 140
                radius: 8
                color: "#2a2a2a"
                visible: mediaTitle !== "" && mediaTitle !== "No Title"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    Row {
                        spacing: 10
                        width: parent.width
                        
                        // Thumbnail
                        Rectangle {
                            width: 60
                            height: 60
                            radius: 6
                            color: "#404040"
                            clip: true
                            
                            Image {
                                anchors.fill: parent
                                source: mediaThumbnail.replace("file://", "")
                                fillMode: Image.PreserveAspectCrop
                                visible: mediaThumbnail !== ""
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰝚"
                                font.pixelSize: 24
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#888888"
                                visible: mediaThumbnail === ""
                            }
                        }
                        
                        // Title and Artist
                        Column {
                            width: parent.width - 70
                            spacing: 4
                            
                            Text {
                                text: mediaTitle
                                font.pixelSize: 13
                                font.family: "JetBrains Mono Nerd Font"
                                font.bold: true
                                color: "#ffffff"
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Text {
                                text: mediaArtist
                                font.pixelSize: 11
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#888888"
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Text {
                                function formatTime(microseconds) {
                                    var seconds = Math.floor(microseconds / 1000000)
                                    var mins = Math.floor(seconds / 60)
                                    var secs = seconds % 60
                                    return mins + ":" + (secs < 10 ? "0" : "") + secs
                                }
                                text: formatTime(mediaPosition) + " / " + formatTime(mediaLength)
                                font.pixelSize: 10
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#666666"
                            }
                        }
                    }
                    
                    // Progress Bar
                    Rectangle {
                        width: parent.width
                        height: 4
                        radius: 2
                        color: "#404040"
                        
                        Rectangle {
                            width: mediaLength > 0 ? (mediaPosition / mediaLength) * parent.width : 0
                            height: parent.height
                            radius: parent.radius
                            color: "#ffffff"
                        }
                    }
                    
                    // Playback Controls
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 15
                        
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: prevBtnArea.containsMouse ? "#404040" : "#2a2a2a"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.pixelSize: 18
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: prevBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: volumeMenuWindow.mediaControl("previous")
                            }
                        }
                        
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: playBtnArea.containsMouse ? "#404040" : "#2a2a2a"
                            
                            Text {
                                anchors.centerIn: parent
                                text: mediaPlaying ? "󰏤" : "󰐊"
                                font.pixelSize: 20
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: playBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: volumeMenuWindow.mediaControl("play-pause")
                            }
                        }
                        
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: nextBtnArea.containsMouse ? "#404040" : "#2a2a2a"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.pixelSize: 18
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: nextBtnArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: volumeMenuWindow.mediaControl("next")
                            }
                        }
                    }
                }
            }
            
            // Volume Header
            Rectangle {
                width: parent.width
                height: 36
                radius: 8
                color: "#2a2a2a"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    
                    Text {
                        property string volIcon: {
                            if (volumeMuted) return "󰝟"
                            if (volumeLevel >= 66) return "󰕾"
                            if (volumeLevel >= 33) return "󰖀"
                            if (volumeLevel > 0) return "󰕿"
                            return "󰝟"
                        }
                        text: volIcon
                        font.pixelSize: 18
                        font.family: "JetBrains Mono Nerd Font"
                        color: volumeMuted ? "#888888" : "#ffffff"
                    }
                    
                    Text {
                        text: "Volume"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: targetVolumeLevel + "%"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono Nerd Font"
                        font.bold: true
                        color: "#ffffff"
                    }
                }
            }
            
            // Volume Slider
            Rectangle {
                width: parent.width
                height: 44
                radius: 8
                color: "#2a2a2a"
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 12
                    
                    Rectangle {
                        id: sliderTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: 3
                        color: "#404040"
                        
                        Rectangle {
                            width: (targetVolumeLevel / 100) * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: "#ffffff"
                        }
                        
                        Rectangle {
                            id: sliderHandle
                            width: 18
                            height: 18
                            radius: 9
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(parent.width - width, (targetVolumeLevel / 100) * (parent.width - width)))
                            
                            MouseArea {
                                id: sliderMouseArea
                                anchors.fill: parent
                                anchors.margins: -10
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                drag.target: sliderHandle
                                drag.axis: Drag.XAxis
                                drag.minimumX: 0
                                drag.maximumX: sliderTrack.width - sliderHandle.width
                                
                                onPressed: {
                                    volumeMenuWindow.volumeDragStarted()
                                }
                                
                                onPositionChanged: {
                                    if (drag.active) {
                                        var percentage = Math.max(0, Math.min(100, (sliderHandle.x / (sliderTrack.width - sliderHandle.width)) * 100))
                                        volumeMenuWindow.volumeChanged(Math.round(percentage))
                                    }
                                }
                                
                                onReleased: {
                                    var percentage = Math.max(0, Math.min(100, (sliderHandle.x / (sliderTrack.width - sliderHandle.width)) * 100))
                                    volumeMenuWindow.volumeDragEnded(Math.round(percentage))
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            enabled: !sliderMouseArea.drag.active
                            onClicked: {
                                var percentage = Math.max(0, Math.min(100, (mouseX / width) * 100))
                                volumeMenuWindow.volumeDragEnded(Math.round(percentage))
                            }
                        }
                    }
                }
            }
        }
    }
}
