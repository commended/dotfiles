import QtQuick

Rectangle {
    id: toggle
    
    property bool checked: false
    property int switchWidth: 40
    property int switchHeight: 22
    
    signal toggled(bool value)
    
    width: switchWidth
    height: switchHeight
    radius: height / 2
    color: checked ? Theme.accent : Theme.surfaceHover
    
    Behavior on color {
        ColorAnimation { duration: Theme.animationDurationFast }
    }
    
    Rectangle {
        width: parent.height - 4
        height: width
        radius: width / 2
        color: checked ? Theme.accentText : Theme.textPrimary
        anchors.verticalCenter: parent.verticalCenter
        x: checked ? parent.width - width - 2 : 2
        
        Behavior on x {
            NumberAnimation { duration: Theme.animationDurationFast }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled(!checked)
    }
}
