import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    property bool barExpanded: true
    property int volumeLevel: 0
    property bool volumeMuted: false
    property bool bluetoothMenuOpen: false
    property var bluetoothDevices: []
    property int batteryLevel: 0
    property bool batteryCharging: false
    property bool trayCollapsed: false
    property bool wifiMenuOpen: false
    property bool wifiEnabled: true
    property string wifiConnected: ""
    property var wifiNetworks: []
    property bool calendarMenuOpen: false
    property date currentDate: new Date()
    property bool volumeMenuOpen: false
    property int targetVolumeLevel: volumeLevel
    property bool isDraggingVolume: false
    
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    var newLevel = Math.round(parseFloat(match[1]) * 100)
                    if (!isDraggingVolume) {
                        volumeLevel = newLevel
                        targetVolumeLevel = newLevel
                    }
                }
                volumeMuted = data.includes("[MUTED]")
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: volWatcher
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered 'sink'"]
        stdout: SplitParser {
            onRead: data => {
                if (!isDraggingVolume) {
                    volProc.running = true
                }
            }
        }
        Component.onCompleted: running = true
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!isDraggingVolume) {
                volProc.running = true
            }
        }
    }
    
    Process {
        id: btListProc
        command: ["bluetoothctl", "devices"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var match = data.match(/Device\s+([A-F0-9:]+)\s+(.+)/)
                if (match) {
                    var newDevices = bluetoothDevices.slice()
                    var exists = newDevices.some(d => d.mac === match[1])
                    if (!exists) {
                        newDevices.push({mac: match[1], name: match[2], connected: false})
                        bluetoothDevices = newDevices
                    }
                }
            }
        }
    }
    
    Process {
        id: btConnectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var match = data.match(/Device\s+([A-F0-9:]+)\s+(.+)/)
                if (match) {
                    var newDevices = bluetoothDevices.slice()
                    for (var i = 0; i < newDevices.length; i++) {
                        if (newDevices[i].mac === match[1]) {
                            newDevices[i].connected = true
                        }
                    }
                    bluetoothDevices = newDevices
                }
            }
        }
    }
    
    Process {
        id: btConnectProc
        property string targetMac: ""
        command: ["bluetoothctl", "connect", targetMac]
        onRunningChanged: {
            if (!running) {
                btRefreshTimer.start()
            }
        }
    }
    
    Process {
        id: btDisconnectProc
        property string targetMac: ""
        command: ["bluetoothctl", "disconnect", targetMac]
        onRunningChanged: {
            if (!running) {
                btRefreshTimer.start()
            }
        }
    }
    
    Timer {
        id: btRefreshTimer
        interval: 500
        onTriggered: {
            bluetoothDevices = []
            btListProc.running = true
            btConnectedProc.running = true
        }
    }
    
    function refreshBluetooth() {
        bluetoothDevices = []
        btListProc.running = true
        btConnectedProc.running = true
    }
    
    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var level = parseInt(data.trim())
                if (!isNaN(level)) {
                    batteryLevel = level
                }
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: batteryStatusProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo Unknown"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                batteryCharging = (data.trim() === "Charging")
            }
        }
        Component.onCompleted: running = true
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryProc.running = true
            batteryStatusProc.running = true
        }
    }
    
    Process {
        id: wifiStatusProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                wifiEnabled = (data.trim() === "enabled")
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: wifiConnectedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.split(":")
                if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                    wifiConnected = parts[0]
                }
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: wifiListProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "device", "wifi", "list"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var parts = data.split(":")
                if (parts.length >= 4 && parts[0] !== "") {
                    var newNetworks = wifiNetworks.slice()
                    var exists = newNetworks.some(n => n.ssid === parts[0])
                    if (!exists) {
                        newNetworks.push({
                            ssid: parts[0],
                            signal: parseInt(parts[1]) || 0,
                            security: parts[2] || "",
                            connected: parts[3] === "*"
                        })
                        wifiNetworks = newNetworks
                    }
                }
            }
        }
    }
    
    Process {
        id: wifiConnectProc
        property string targetSSID: ""
        command: ["nmcli", "device", "wifi", "connect", targetSSID]
        onRunningChanged: {
            if (!running) {
                wifiRefreshTimer.start()
            }
        }
    }
    
    Process {
        id: wifiDisconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]
        onRunningChanged: {
            if (!running) {
                wifiRefreshTimer.start()
            }
        }
    }
    
    Process {
        id: wifiToggleProc
        property bool enabling: true
        command: ["nmcli", "radio", "wifi", enabling ? "on" : "off"]
        onRunningChanged: {
            if (!running) {
                wifiRefreshTimer.start()
            }
        }
    }
    
    Timer {
        id: wifiRefreshTimer
        interval: 1000
        onTriggered: {
            wifiNetworks = []
            wifiConnected = ""
            wifiStatusProc.running = true
            wifiConnectedProc.running = true
            wifiListProc.running = true
        }
    }
    
    function refreshWifi() {
        wifiNetworks = []
        wifiConnected = ""
        wifiStatusProc.running = true
        wifiConnectedProc.running = true
        wifiListProc.running = true
    }
    
    Process {
        id: volSetProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0"]
        
        function setVolume(level) {
            command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (level / 100).toFixed(2)]
            running = true
        }
    }
    
    // Volume Dropdown Window
    PopupWindow {
        id: volumeMenuWindow
        visible: volumeMenuOpen || volCloseAnim.running
        width: 280
        height: 120
        
        parentWindow: bar
        relativeX: bar.width - width - 1
        relativeY: barExpanded ? 40 : 15
        
        color: "transparent"
        
        Item {
            anchors.fill: parent
            scale: volumeMenuOpen ? 1.0 : 0.0
            opacity: volumeMenuOpen ? 1.0 : 0.0
            transformOrigin: Item.Top
            
            Behavior on scale {
                NumberAnimation {
                    id: volCloseAnim
                    duration: 200
                    easing.type: volumeMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: volumeMenuOpen ? Easing.OutCubic : Easing.InCubic
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
                                        isDraggingVolume = true
                                    }
                                    
                                    onPositionChanged: {
                                        if (drag.active) {
                                            var percentage = Math.max(0, Math.min(100, (sliderHandle.x / (sliderTrack.width - sliderHandle.width)) * 100))
                                            targetVolumeLevel = Math.round(percentage)
                                        }
                                    }
                                    
                                    onReleased: {
                                        volumeLevel = targetVolumeLevel
                                        volSetProc.setVolume(targetVolumeLevel)
                                        isDraggingVolume = false
                                    }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: !sliderMouseArea.drag.active
                                onClicked: {
                                    var percentage = Math.max(0, Math.min(100, (mouseX / width) * 100))
                                    targetVolumeLevel = Math.round(percentage)
                                    volumeLevel = targetVolumeLevel
                                    volSetProc.setVolume(targetVolumeLevel)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Bluetooth Dropdown Window
    PopupWindow {
        id: bluetoothMenuWindow
        visible: bluetoothMenuOpen || btCloseAnim.running
        width: 280
        height: Math.max(btDevicesList.height + 30, 150)
        
        parentWindow: bar
        relativeX: bar.width - 300
        relativeY: barExpanded ? 40 : 15
        
        color: "transparent"
        
        Item {
            anchors.fill: parent
            scale: bluetoothMenuOpen ? 1.0 : 0.0
            opacity: bluetoothMenuOpen ? 1.0 : 0.0
            transformOrigin: Item.Top
            
            Behavior on scale {
                NumberAnimation {
                    id: btCloseAnim
                    duration: 200
                    easing.type: bluetoothMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: bluetoothMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
        
            Canvas {
                id: btBowlShape
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
            id: btDevicesList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 8
            
            Repeater {
                model: bluetoothDevices
                
                Rectangle {
                    width: btDevicesList.width
                    height: 36
                    radius: 4
                    color: btDeviceMouseArea.containsMouse ? "#505050" : (modelData.connected ? "#404040" : "#2a2a2a")
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 8
                        
                        Text {
                            text: modelData.name
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: modelData.connected ? "#ffffff" : "#ffffff"
                        }
                        
                        Text {
                            text: modelData.connected ? "󰂱" : "󰂯"
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: modelData.connected ? "#ffffff" : "#888888"
                        }
                    }
                    
                    MouseArea {
                        id: btDeviceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected) {
                                btDisconnectProc.targetMac = modelData.mac
                                btDisconnectProc.running = true
                            } else {
                                btConnectProc.targetMac = modelData.mac
                                btConnectProc.running = true
                            }
                        }
                    }
                }
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No devices found"
                font.pixelSize: 12
                font.family: "JetBrains Mono Nerd Font"
                color: "#888888"
                visible: bluetoothDevices.length === 0
            }
        }
        }
    }
    
    // WiFi Dropdown Window
    PopupWindow {
        id: wifiMenuWindow
        visible: wifiMenuOpen || wifiCloseAnim.running
        width: 320
        height: 400
        
        parentWindow: bar
        relativeX: bar.width - 380
        relativeY: barExpanded ? 40 : 15
        
        color: "transparent"
        
        Item {
            anchors.fill: parent
            scale: wifiMenuOpen ? 1.0 : 0.0
            opacity: wifiMenuOpen ? 1.0 : 0.0
            transformOrigin: Item.Top
            
            Behavior on scale {
                NumberAnimation {
                    id: wifiCloseAnim
                    duration: 200
                    easing.type: wifiMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: wifiMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
        
            Canvas {
                id: wifiBowlCanvas
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
            id: wifiContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10
            
            // WiFi Toggle
            Rectangle {
                width: parent.width
                height: 44
                radius: 8
                color: "#2a2a2a"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    Text {
                        text: "󰤨  WiFi"
                        font.pixelSize: 16
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: wifiEnabled ? "#ffffff" : "#404040"
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: wifiEnabled ? "#1a1a1a" : "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                            x: wifiEnabled ? parent.width - width - 2 : 2
                            
                            Behavior on x {
                                NumberAnimation { duration: 150 }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wifiToggleProc.enabling = !wifiEnabled
                                wifiToggleProc.running = true
                            }
                        }
                    }
                }
            }
            
            // Connected network
            Rectangle {
                width: parent.width
                height: wifiConnected !== "" ? 30 : 0
                radius: 4
                color: "#404040"
                visible: wifiConnected !== ""
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8
                    
                    Text {
                        text: "󰤨"
                        font.pixelSize: 14
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: wifiConnected
                        font.pixelSize: 12
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Disconnect"
                        font.pixelSize: 10
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ff6b6b"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wifiDisconnectProc.running = true
                            }
                        }
                    }
                }
            }
            
            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: "#404040"
                visible: wifiEnabled && wifiNetworks.length > 0
            }
            
            // Network list
            ListView {
                id: wifiListView
                width: parent.width
                height: 200
                model: wifiNetworks
                spacing: 6
                interactive: true
                clip: true
                visible: wifiEnabled
                
                delegate: Rectangle {
                    width: wifiListView.width
                    height: 36
                    radius: 6
                    color: wifiNetMouseArea.containsMouse ? "#505050" : "#2a2a2a"
                    visible: !modelData.connected
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 8
                        
                        Text {
                            property string signalIcon: {
                                if (modelData.signal >= 75) return "󰤨"
                                if (modelData.signal >= 50) return "󰤥"
                                if (modelData.signal >= 25) return "󰤢"
                                return "󰤟"
                            }
                            text: signalIcon
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#888888"
                        }
                        
                        Text {
                            text: modelData.ssid
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.security !== "" ? "󰌾" : ""
                            font.pixelSize: 10
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#888888"
                        }
                    }
                    
                    MouseArea {
                        id: wifiNetMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiConnectProc.targetSSID = modelData.ssid
                            wifiConnectProc.running = true
                        }
                    }
                }
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: wifiEnabled ? "No networks found" : "WiFi disabled"
                font.pixelSize: 12
                font.family: "JetBrains Mono Nerd Font"
                color: "#888888"
                visible: !wifiEnabled || wifiNetworks.length === 0
            }
        }
        }
    }
    
    // Calendar Dropdown Window
    PopupWindow {
        id: calendarMenuWindow
        visible: calendarMenuOpen || calCloseAnim.running
        width: 320
        height: 360
        
        parentWindow: bar
        relativeX: (bar.width - width) / 2
        relativeY: barExpanded ? 40 : 15
        
        color: "transparent"
        
        Item {
            anchors.fill: parent
            scale: calendarMenuOpen ? 1.0 : 0.0
            opacity: calendarMenuOpen ? 1.0 : 0.0
            transformOrigin: Item.Top
            
            Behavior on scale {
                NumberAnimation {
                    id: calCloseAnim
                    duration: 200
                    easing.type: calendarMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: calendarMenuOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
        
            Canvas {
                id: calBowlCanvas
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
                
                // Month/Year header
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 8
                    color: "#2a2a2a"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        Text {
                            text: "◄"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var newDate = new Date(currentDate)
                                    newDate.setMonth(newDate.getMonth() - 1)
                                    currentDate = newDate
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: Qt.formatDateTime(currentDate, "MMMM yyyy")
                            font.pixelSize: 16
                            font.family: "JetBrains Mono Nerd Font"
                            font.bold: true
                            color: "#ffffff"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "►"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono Nerd Font"
                            color: "#ffffff"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var newDate = new Date(currentDate)
                                    newDate.setMonth(newDate.getMonth() + 1)
                                    currentDate = newDate
                                }
                            }
                        }
                    }
                }
                
                // Weekday headers
                Grid {
                    columns: 7
                    spacing: 4
                    width: parent.width
                    
                    Repeater {
                        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                        
                        Text {
                            text: modelData
                            font.pixelSize: 12
                            font.family: "JetBrains Mono Nerd Font"
                            font.bold: true
                            color: "#888888"
                            width: (parent.parent.width - 6 * parent.spacing) / 7
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                // Calendar grid
                Grid {
                    id: calendarGrid
                    columns: 7
                    spacing: 4
                    width: parent.width
                    
                    Repeater {
                        model: {
                            var days = []
                            var firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
                            var lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0)
                            var startOffset = firstDay.getDay()
                            var today = new Date()
                            
                            // Add empty cells for days before month starts
                            for (var i = 0; i < startOffset; i++) {
                                days.push({day: 0, isToday: false, isCurrentMonth: false})
                            }
                            
                            // Add days of the month
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
                            radius: 6
                            color: modelData.isToday ? "#ffffff" : (modelData.day > 0 ? "#2a2a2a" : "transparent")
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.day > 0 ? modelData.day : ""
                                font.pixelSize: 13
                                font.family: "JetBrains Mono Nerd Font"
                                font.bold: modelData.isToday
                                color: modelData.isToday ? "#1a1a1a" : "#ffffff"
                            }
                        }
                    }
                }
                
                // Today button
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 8
                    color: todayBtnArea.containsMouse ? "#404040" : "#2a2a2a"
                    
                    Text {
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(new Date(), "M/d/yy")
                        font.pixelSize: 13
                        font.family: "JetBrains Mono Nerd Font"
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: todayBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentDate = new Date()
                        }
                    }
                }
            }
        }
    }
    
    PanelWindow {
        id: bar
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        height: 72
        
        margins {
            bottom: barExpanded ? 0 : -35
        }
        
        exclusiveZone: barExpanded ? 40 : 5
        
        color: "transparent"
        
        Behavior on margins.bottom {
            NumberAnimation {
                duration: 300
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
                color: "#1a1a1a"
                radius: 0
                
                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 12
                    color: "#1a1a1a"
                    radius: 12
                    visible: barExpanded
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12
                    opacity: barExpanded ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                    
                    // Workspaces
                    Row {
                        spacing: 6
                        
                        Repeater {
                            model: 5
                            
                            Rectangle {
                                property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
                                property bool hasWindows: {
                                    for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                                        if (Hyprland.workspaces.values[i].id === (index + 1)) {
                                            return true;
                                        }
                                    }
                                    return false;
                                }
                                
                                width: 32
                                height: 24
                                radius: 6
                                color: isActive ? "#ffffff" : (hasWindows ? "#404040" : "#2a2a2a")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                                    font.pixelSize: 12
                                    font.bold: parent.isActive
                                    color: parent.isActive ? "#1a1a1a" : "#ffffff"
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        Hyprland.dispatch("workspace " + (index + 1))
                                    }
                                }
                            }
                        }
                    }
                    
                    // Spacer
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    // Tray Container
                    Row {
                        spacing: 0
                        
                        // Collapse Arrow
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: trayArrowArea.containsMouse ? "#404040" : "#2a2a2a"
                            
                            Text {
                                anchors.centerIn: parent
                                text: trayCollapsed ? "<" : ">"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono Nerd Font"
                                color: "#ffffff"
                            }
                            
                            MouseArea {
                                id: trayArrowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: trayCollapsed = !trayCollapsed
                            }
                        }
                        
                        // Tray Bubble
                        Rectangle {
                            width: trayCollapsed ? 0 : trayRow.width + 20
                            height: 24
                            radius: 6
                            color: "#2a2a2a"
                            clip: true
                            
                            Behavior on width {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            
                            Row {
                                id: trayRow
                                anchors.centerIn: parent
                                spacing: 12
                                opacity: trayCollapsed ? 0.0 : 1.0
                                
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                                
                                // WiFi
                                Text {
                                    property string wifiIcon: {
                                        if (!wifiEnabled) return "󰤭"
                                        if (wifiConnected === "") return "󰤯"
                                        return "󰤨"
                                    }
                                    text: wifiIcon
                                    font.pixelSize: 16
                                    font.family: "JetBrains Mono Nerd Font"
                                    color: wifiEnabled ? "#ffffff" : "#888888"
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            wifiMenuOpen = !wifiMenuOpen
                                            bluetoothMenuOpen = false
                                            if (wifiMenuOpen) {
                                                refreshWifi()
                                            }
                                        }
                                    }
                                }
                                
                                // Bluetooth
                                Text {
                                    text: "󰂯"
                                    font.pixelSize: 16
                                    font.family: "JetBrains Mono Nerd Font"
                                    color: "#ffffff"
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            bluetoothMenuOpen = !bluetoothMenuOpen
                                            wifiMenuOpen = false
                                            if (bluetoothMenuOpen) {
                                                refreshBluetooth()
                                            }
                                        }
                                    }
                                }
                                
                                // Battery
                                Text {
                                    property string batteryIcon: {
                                        if (batteryCharging) return "󰂄"
                                        if (batteryLevel >= 90) return "󰁹"
                                        if (batteryLevel >= 80) return "󰂂"
                                        if (batteryLevel >= 70) return "󰂁"
                                        if (batteryLevel >= 60) return "󰂀"
                                        if (batteryLevel >= 50) return "󰁿"
                                        if (batteryLevel >= 40) return "󰁾"
                                        if (batteryLevel >= 30) return "󰁽"
                                        if (batteryLevel >= 20) return "󰁼"
                                        if (batteryLevel >= 10) return "󰁻"
                                        return "󰁺"
                                    }
                                    text: batteryIcon + " " + batteryLevel + "%"
                                    font.pixelSize: 14
                                    font.family: "JetBrains Mono Nerd Font"
                                    color: batteryLevel <= 20 && !batteryCharging ? "#ff6b6b" : "#ffffff"
                                }
                                
                                // Volume
                                Text {
                                    property string volIcon: {
                                        if (volumeMuted) return "󰝟"
                                        if (volumeLevel >= 66) return "󰕾"
                                        if (volumeLevel >= 33) return "󰖀"
                                        if (volumeLevel > 0) return "󰕿"
                                        return "󰝟"
                                    }
                                    text: volIcon + " " + volumeLevel + "%"
                                    font.pixelSize: 14
                                    font.family: "JetBrains Mono Nerd Font"
                                    color: volumeMuted ? "#888888" : "#ffffff"
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            volumeMenuOpen = !volumeMenuOpen
                                            wifiMenuOpen = false
                                            bluetoothMenuOpen = false
                                            calendarMenuOpen = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Clock - positioned absolutely in center
                Text {
                    id: clock
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    font.family: "JetBrains Mono Nerd Font"
                    color: "#ffffff"
                    z: 100
                    opacity: barExpanded ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            clock.text = Qt.formatDateTime(new Date(), "hh:mm")
                        }
                        Component.onCompleted: triggered()
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!barExpanded) return
                            calendarMenuOpen = !calendarMenuOpen
                            bluetoothMenuOpen = false
                            wifiMenuOpen = false
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
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
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
                        ctx.fillStyle = "#1a1a1a"
                        
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
                    font.pixelSize: 14
                    color: "#ffffff"
                    opacity: (toggleMouseArea.containsMouse || toggleHoverArea.containsMouse) ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                MouseArea {
                    id: toggleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        barExpanded = !barExpanded
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
