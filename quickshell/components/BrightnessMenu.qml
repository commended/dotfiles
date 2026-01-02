import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PopupWindow {
    id: brightnessMenuWindow

    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property int brightnessLevel
    required property int targetBrightnessLevel
    required property bool isDraggingBrightness

    signal brightnessChanged(int level)
    signal brightnessDragStarted()
    signal brightnessDragEnded(int level)

    visible: menuOpen || brightnessCloseAnim.running
    width: 80
    height: 240

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
                id: brightnessCloseAnim
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
            id: brightnessBowlCanvas
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
            anchors.margins: Theme.marginDefault
            spacing: Theme.spacingLarge

            // Brightness Icon
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰃠"
                font.pixelSize: Theme.fontSizeIconLarge
                font.family: Theme.fontFamily
                color: Theme.textPrimary
            }

            Item { height: 5 }

            // Vertical Slider
            Item {
                width: parent.width
                height: parent.height - 53

                Rectangle {
                    id: sliderTrack
                    anchors.centerIn: parent
                    width: 8
                    height: parent.height
                    radius: 4
                    color: Theme.surfaceHover

                    Rectangle {
                        id: sliderFill
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: parent.height * (targetBrightnessLevel / 100)
                        radius: 4
                        color: Theme.accent
                    }
                }

                Rectangle {
                    id: sliderHandle
                    width: 20
                    height: 20
                    radius: 10
                    color: Theme.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    property bool localDragging: false
                    property real dragStartMouseY: 0
                    property real dragStartHandleY: 0
                    property real initialMouseYInTrack: 0
                    y: sliderTrack.y + Math.max(0, Math.min(sliderTrack.height - sliderHandle.height, (1 - (targetBrightnessLevel/100)) * (sliderTrack.height - sliderHandle.height)))

                    MouseArea {
                        id: sliderMouseArea
                        anchors.fill: parent
                        anchors.margins: -10
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: {
                            sliderHandle.localDragging = true
                            sliderHandle.initialMouseYInTrack = mapToItem(sliderTrack, mouse.x, mouse.y).y
                            sliderHandle.dragStartHandleY = sliderHandle.y
                            brightnessMenuWindow.brightnessDragStarted()
                        }

                        onPositionChanged: {
                            if (sliderHandle.localDragging) {
                                var currentMouseYInTrack = mapToItem(sliderTrack, mouse.x, mouse.y).y
                                var delta = currentMouseYInTrack - sliderHandle.initialMouseYInTrack
                                var newY = sliderHandle.dragStartHandleY + delta
                                var minY = sliderTrack.y
                                var maxY = sliderTrack.y + sliderTrack.height - sliderHandle.height
                                newY = Math.max(minY, Math.min(maxY, newY))
                                sliderHandle.y = newY
                                var rel = newY - sliderTrack.y
                                var percentage = Math.max(0, Math.min(100, (1 - (rel / (sliderTrack.height - sliderHandle.height))) * 100))
                                brightnessMenuWindow.brightnessChanged(Math.round(percentage))
                            }
                        }

                        onReleased: {
                            if (sliderHandle.localDragging) {
                                sliderHandle.localDragging = false
                                var rel = sliderHandle.y - sliderTrack.y
                                var percentage = Math.max(0, Math.min(100, (1 - (rel / (sliderTrack.height - sliderHandle.height))) * 100))
                                brightnessMenuWindow.brightnessDragEnded(Math.round(percentage))
                            }
                        }
                    }

                    Binding {
                        target: sliderHandle
                        property: "y"
                        value: sliderTrack.y + Math.max(0, Math.min(sliderTrack.height - sliderHandle.height, (1 - (targetBrightnessLevel/100)) * (sliderTrack.height - sliderHandle.height)))
                        when: !sliderHandle.localDragging
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: (mouse) => {
                        var rel = mouse.y - sliderTrack.y
                        var denom = Math.max(1, (sliderTrack.height - sliderHandle.height))
                        var percentage = 100 - Math.round((rel / denom) * 100)
                        percentage = Math.max(0, Math.min(100, percentage))
                        brightnessMenuWindow.brightnessDragEnded(percentage)
                    }
                }
            }
        }
    }
}
