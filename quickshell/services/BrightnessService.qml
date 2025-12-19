import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: brightnessService

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances
    property bool appleDisplayPresent: false
    property bool isDraggingBrightness: false
    property real brightnessLevel: getMonitor("active")?.brightness * 100 ?? 0
    property real targetBrightnessLevel: brightnessLevel

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData === screen);
    }

    function getMonitor(query: string): var {
        if (query === "active") {
            return monitors.find(m => Hyprland.monitorFor(m.modelData)?.focused);
        }

        if (query.startsWith("model:")) {
            const model = query.slice(6);
            return monitors.find(m => m.modelData.model === model);
        }

        if (query.startsWith("serial:")) {
            const serial = query.slice(7);
            return monitors.find(m => m.modelData.serialNumber === serial);
        }

        if (query.startsWith("id:")) {
            const id = parseInt(query.slice(3), 10);
            return monitors.find(m => Hyprland.monitorFor(m.modelData)?.id === id);
        }

        return monitors.find(m => m.modelData.name === query);
    }

    function increaseBrightness(): void {
        const monitor = getMonitor("active");
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.1);
    }

    function decreaseBrightness(): void {
        const monitor = getMonitor("active");
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.1);
    }

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants

        model: Quickshell.screens

        Monitor {}
    }

    Process {
        running: true
        command: ["sh", "-c", "asdbctl get"] // To avoid warnings if asdbctl is not installed
        stdout: StdioCollector {
            onStreamFinished: appleDisplayPresent = text.trim().length > 0
        }
    }

    Process {
        id: ddcProc

        command: ["ddcutil", "detect", "--brief"]
        stdout: StdioCollector {
            onStreamFinished: ddcMonitors = text.trim().split("\n\n").filter(d => d.startsWith("Display ")).map(d => ({
                        busNum: d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/)[1],
                        connector: d.match(/DRM connector:\s+(.*)/)[1].replace(/^card\d+-/, "") // strip "card1-"
                    }))
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if (!isDraggingBrightness) {
                for (const monitor of monitors) {
                    monitor.refreshBrightness()
                }
                // update service-level brightness values from the active monitor
                var active = getMonitor("active")
                var pct = 0
                if (active && !isNaN(active.brightness)) pct = Math.round(active.brightness * 100)
                brightnessService.brightnessLevel = pct
                brightnessService.targetBrightnessLevel = pct
            }
        }
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: brightnessService.ddcMonitors.some(m => m.connector === modelData.name)
        readonly property string busNum: brightnessService.ddcMonitors.find(m => m.connector === modelData.name)?.busNum ?? ""
        readonly property bool isAppleDisplay: brightnessService.appleDisplayPresent && modelData.model.startsWith("StudioDisplay")
        property real brightness
        property real queuedBrightness: NaN

        readonly property Process refreshProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
                    if (monitor.isAppleDisplay) {
                        const val = parseInt(text.trim());
                        monitor.brightness = val / 101;
                    } else {
                        const [, , , cur, max] = text.split(" ");
                        monitor.brightness = parseInt(cur) / parseInt(max);
                    }
                }
            }
        }

        readonly property Timer timer: Timer {
            interval: 500
            onTriggered: {
                if (!isNaN(monitor.queuedBrightness)) {
                    monitor.setBrightness(monitor.queuedBrightness);
                    monitor.queuedBrightness = NaN;
                }
            }
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;

            brightness = value;

            Quickshell.execDetached(["brightnessctl", "s", `${rounded}%`]);
        }

        function refreshBrightness(): void {
            refreshProc.command = ["sh", "-c", "echo a b c $(brightnessctl g) $(brightnessctl m)"];

            refreshProc.running = true;
        }

        onBusNumChanged: refreshBrightness()
        Component.onCompleted: refreshBrightness()
    }
}
