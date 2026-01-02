import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PopupWindow {
    id: calendarMenuWindow
    
    required property var barWindow
    required property bool barExpanded
    required property bool menuOpen
    required property date currentDate
    
    signal dateChanged(date newDate)
    
    visible: menuOpen || calCloseAnim.running
    width: 320
    height: 360
    
    anchor.window: barWindow
    anchor.rect.x: (barWindow.width - width) / 2
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
                id: calCloseAnim
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
            id: calBowlCanvas
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
            anchors.fill: parent
            anchors.margins: Theme.marginLarge
            spacing: Theme.spacingLarge
            
            // Month/Year header
            Rectangle {
                width: parent.width
                height: 40
                radius: Theme.radiusMedium
                color: Theme.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMedium
                    
                    Text {
                        text: "◄"
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var newDate = new Date(currentDate)
                                newDate.setMonth(newDate.getMonth() - 1)
                                calendarMenuWindow.dateChanged(newDate)
                            }
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: Qt.formatDateTime(currentDate, "MMMM yyyy")
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: Theme.fontFamily
                        font.bold: true
                        color: Theme.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "►"
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var newDate = new Date(currentDate)
                                newDate.setMonth(newDate.getMonth() + 1)
                                calendarMenuWindow.dateChanged(newDate)
                            }
                        }
                    }
                }
            }
            
            // Weekday headers
            Grid {
                columns: 7
                spacing: Theme.spacingSmall
                width: parent.width
                
                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    
                    Text {
                        text: modelData
                        font.pixelSize: Theme.fontSizeDefault
                        font.family: Theme.fontFamily
                        font.bold: true
                        color: Theme.textSecondary
                        width: (parent.parent.width - 6 * parent.spacing) / 7
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
            
            // Calendar grid
            Grid {
                id: calendarGrid
                columns: 7
                spacing: Theme.spacingSmall
                width: parent.width
                
                Repeater {
                    model: {
                        var days = []
                        var firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
                        var lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0)
                        var startOffset = firstDay.getDay()
                        var today = new Date()
                        
                        for (var i = 0; i < startOffset; i++) {
                            days.push({day: 0, isToday: false, isCurrentMonth: false})
                        }
                        
                        for (var d = 1; d <= lastDay.getDate(); d++) {
                            var isToday = (d === today.getDate() && 
                                         currentDate.getMonth() === today.getMonth() && 
                                         currentDate.getFullYear() === today.getFullYear())
                            days.push({day: d, isToday: isToday, isCurrentMonth: true})
                        }
                        
                        return days
                    }
                    
                    Rectangle {
                        width: (calendarGrid.width - 6 * calendarGrid.spacing) / 7
                        height: width
                        radius: Theme.radiusSmall
                        color: modelData.isToday ? Theme.accent : (modelData.day > 0 ? Theme.surface : "transparent")
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.day > 0 ? modelData.day : ""
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            font.bold: modelData.isToday
                            color: modelData.isToday ? Theme.accentText : Theme.textPrimary
                        }
                    }
                }
            }
            
            // Today button
            Rectangle {
                width: parent.width
                height: 32
                radius: Theme.radiusMedium
                color: todayBtnArea.containsMouse ? Theme.surfaceHover : Theme.surface
                
                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(new Date(), "M/d/yy")
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    color: Theme.textPrimary
                }
                
                MouseArea {
                    id: todayBtnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calendarMenuWindow.dateChanged(new Date())
                }
            }
        }
    }
}
