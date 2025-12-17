import QtQuick
import Quickshell.Io

Item {
    id: volumeService
    
    property int volumeLevel: 0
    property bool volumeMuted: false
    property int targetVolumeLevel: volumeLevel
    property bool isDraggingVolume: false
    
    function setVolume(level) {
        volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (level / 100).toFixed(2)]
        volSetProc.running = true
    }
    
    function refresh() {
        if (!isDraggingVolume) {
            volProc.running = true
        }
    }
    
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match && !isDraggingVolume) {
                    var newLevel = Math.round(parseFloat(match[1]) * 100)
                    volumeLevel = newLevel
                    targetVolumeLevel = newLevel
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
                if (!isDraggingVolume) volProc.running = true
            }
        }
        Component.onCompleted: running = true
    }
    
    Process {
        id: volSetProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0"]
    }
}
