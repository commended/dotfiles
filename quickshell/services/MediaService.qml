import QtQuick
import Quickshell.Io

Item {
    id: mediaService
    
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaThumbnail: ""
    property bool mediaPlaying: false
    property int mediaLength: 0
    property int mediaPosition: 0
    
    function refresh() {
        mediaInfoProc.running = true
    }
    
    function control(action) {
        mediaControlProc.command = ["playerctl", action]
        mediaControlProc.running = true
    }
    
    Process {
        id: mediaInfoProc
        command: ["playerctl", "metadata", "--format", "{{title}}|||{{artist}}|||{{mpris:artUrl}}|||{{status}}|||{{mpris:length}}|||{{position}}"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") {
                    mediaTitle = ""
                    return
                }
                var parts = data.split("|||")
                if (parts.length >= 6) {
                    mediaTitle = parts[0] || ""
                    mediaArtist = parts[1] || ""
                    mediaThumbnail = parts[2] || ""
                    mediaPlaying = parts[3] === "Playing"
                    mediaLength = parseInt(parts[4]) || 0
                    mediaPosition = parseInt(parts[5]) || 0
                }
            }
        }
        stderr: SplitParser {
            onRead: data => mediaTitle = ""
        }
    }
    
    Process {
        id: mediaControlProc
        command: ["playerctl", "play-pause"]
    }
}
