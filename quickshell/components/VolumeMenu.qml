import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

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
    anchor.rect.x: barWindow.width - width - 15
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
            id: volBowlCanvas
            anchors.fill: parent
        
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = Theme.background
                
                var radius = Theme.radiusFull
                
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
        
        Column {
            anchors.fill: parent
            anchors.margins: Theme.marginLarge
            spacing: Theme.spacingLarge
            
            // Media Player Section
            Rectangle {
                width: parent.width
                height: 140
                radius: Theme.radiusMedium
                color: Theme.surface
                visible: mediaTitle !== "" && mediaTitle !== "No Title"
                
                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.marginDefault
                    spacing: Theme.spacingMedium
                    
                    Row {
                        spacing: Theme.marginDefault
                        width: parent.width
                        
                        // Thumbnail
                        Rectangle {
                            width: 60
                            height: 60
                            radius: Theme.radiusSmall
                            color: Theme.surfaceHover
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
                                font.pixelSize: Theme.fontSizeIconLarge
                                font.family: Theme.fontFamily
                                color: Theme.textSecondary
                                visible: mediaThumbnail === ""
                            }
                        }
                        
                        // Title and Artist
                        Column {
                            width: parent.width - 70
                            spacing: Theme.spacingSmall
                            
                            Text {
                                text: mediaTitle
                                font.pixelSize: 13
                                font.family: Theme.fontFamily
                                font.bold: true
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Text {
                                text: mediaArtist
                                font.pixelSize: 11
                                font.family: Theme.fontFamily
                                color: Theme.textSecondary
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            Text {
                                text: Theme.formatTime(mediaPosition) + " / " + Theme.formatTime(mediaLength)
                                font.pixelSize: Theme.fontSizeSmall
                                font.family: Theme.fontFamily
                                color: Theme.textDisabled
                            }
                        }
                    }
                    
                    // Progress Bar
                    Rectangle {
                        width: parent.width
                        height: 4
                        radius: 2
                        color: Theme.surfaceHover
                        
                        Rectangle {
                            width: mediaLength > 0 ? (mediaPosition / mediaLength) * parent.width : 0
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accent
                        }
                    }
                    
                    // Playback Controls
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.marginLarge
                        
                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.radiusRound
                            color: prevBtnArea.containsMouse ? Theme.surfaceHover : Theme.surface
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.pixelSize: Theme.fontSizeIcon
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
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
                            color: playBtnArea.containsMouse ? Theme.surfaceHover : Theme.surface
                            
                            Text {
                                anchors.centerIn: parent
                                text: mediaPlaying ? "󰏤" : "󰐊"
                                font.pixelSize: Theme.fontSizeXLarge
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
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
                            radius: Theme.radiusRound
                            color: nextBtnArea.containsMouse ? Theme.surfaceHover : Theme.surface
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.pixelSize: Theme.fontSizeIcon
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
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
                radius: Theme.radiusMedium
                color: Theme.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMedium
                    spacing: Theme.marginDefault
                    
                    Text {
                        text: Theme.getVolumeIcon(volumeLevel, volumeMuted)
                        font.pixelSize: Theme.fontSizeIcon
                        font.family: Theme.fontFamily
                        color: volumeMuted ? Theme.textSecondary : Theme.textPrimary
                    }
                    
                    Text {
                        text: "Volume"
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: targetVolumeLevel + "%"
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: Theme.fontFamily
                        font.bold: true
                        color: Theme.textPrimary
                    }
                }
            }
            
            // Volume Slider
            Rectangle {
                width: parent.width
                height: 44
                radius: Theme.radiusMedium
                color: Theme.surface
                
                Item {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingLarge
                    
                    Rectangle {
                        id: sliderTrack
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Theme.surfaceHover
                        
                        Rectangle {
                            width: (targetVolumeLevel / 100) * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accent
                        }
                        
                        Rectangle {
                            id: sliderHandle
                            width: 18
                            height: 18
                            radius: 9
                            color: Theme.accent
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
                                
                                onPressed: volumeMenuWindow.volumeDragStarted()
                                
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
