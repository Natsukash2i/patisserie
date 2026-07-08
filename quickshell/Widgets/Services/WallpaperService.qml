import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    // ── Public API ─────────────────────────────────────────────────────────

    /// Directory to scan. Change this to point at your wallpaper folder.
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"

    /// All discovered image paths (sorted)
    property var wallpaperPaths: []

    /// Currently active wallpaper path
    property string currentWallpaper: ""

    function refresh() {
        _scan()
    }

    function showPicker() {
        zenityProcess.command = [
            "bash", "-c",
            "tmp=$(mktemp); ghostty -e yazi --chooser-file=\"$tmp\" \"" + root.wallpaperDirectory + "\"; cat \"$tmp\"; rm -f \"$tmp\""
        ]
        zenityProcess.running = true
    }

    /// Set wallpaper by absolute path
    function setWallpaper(path) {
        if (!path) return
        var idx = wallpaperPaths.indexOf(path)
        if (idx !== -1) _currentIndex = idx
        currentWallpaper = path
        _saveState()
    }

    /// Advance to the next wallpaper
    function next() {
        if (wallpaperPaths.length === 0) return
        _currentIndex = (_currentIndex + 1) % wallpaperPaths.length
        currentWallpaper = wallpaperPaths[_currentIndex]
        _saveState()
    }

    /// Go back to the previous wallpaper
    function previous() {
        if (wallpaperPaths.length === 0) return
        _currentIndex = _currentIndex > 0 ? _currentIndex - 1 : wallpaperPaths.length - 1
        currentWallpaper = wallpaperPaths[_currentIndex]
        _saveState()
    }

    /// Pick a random wallpaper (never repeats the current one)
    function random() {
        if (wallpaperPaths.length === 0) return
        var idx = _currentIndex
        if (wallpaperPaths.length > 1) {
            while (idx === _currentIndex)
                idx = Math.floor(Math.random() * wallpaperPaths.length)
        }
        _currentIndex = idx
        currentWallpaper = wallpaperPaths[_currentIndex]
        _saveState()
    }

    /// Set wallpaper directory and rescan
    function setDirectory(dir) {
        wallpaperDirectory = dir
        _scan()
    }

    // ── Internal ───────────────────────────────────────────────────────────

    property int  _currentIndex: 0
    property bool _initialized:  false

    property string _cacheFile: Quickshell.env("HOME") + "/.cache/quickshell/wallpaper.json"

    function _scan() {
        if (!wallpaperDirectory) return
        
        if (scanProcess.running) return 

        // UPDATED: Added video formats to the find command matching array
        var cmd = [
            "find", wallpaperDirectory,
            "-type", "f",
            "(", "-iname", "*.jpg", "-o",
                 "-iname", "*.jpeg", "-o",
                 "-iname", "*.png", "-o",
                 "-iname", "*.webp", "-o",
                 "-iname", "*.bmp", "-o",
                 "-iname", "*.tiff", "-o",
                 "-iname", "*.tif", "-o",
                 "-iname", "*.mp4", "-o",
                 "-iname", "*.webm", "-o",
                 "-iname", "*.mkv", "-o",
                 "-iname", "*.mov", "-o",
                 "-iname", "*.avi", ")",
            "-not", "-name", ".*",
            "-print"
        ]
        scanProcess.command = cmd
        scanProcess.running = true
    }

    function _saveState() {
        var data = JSON.stringify({
            "wallpaperDirectory": wallpaperDirectory,
            "currentWallpaper":   currentWallpaper
        })
        saveProcess.command = [
            "bash", "-c",
            "mkdir -p \"$(dirname '" + _cacheFile + "')\" && echo '" + data.replace(/'/g, "'\\''") + "' > '" + _cacheFile + "'"
        ]
        saveProcess.running = true
    }

    // ── IPC ────────────────────────────────────────────────────────────────

    IpcHandler {
        target: "wallpaper"

        function showPicker(): string {
            root.showPicker()
            return "launched"
        }

        function next(): string {
            root.next()
            return root.currentWallpaper
        }

        function previous(): string {
            root.previous()
            return root.currentWallpaper
        }

        function random(): string {
            root.random()
            return root.currentWallpaper
        }

        function set(path: string): string {
            root.setWallpaper(path)
            return root.currentWallpaper
        }

        function current(): string {
            return root.currentWallpaper
        }

        function list(): string {
            return root.wallpaperPaths.join("\n")
        }

        function setDir(dir: string): string {
            root.setDirectory(dir)
            return dir
        }
    }

    // ── Processes ──────────────────────────────────────────────────────────

    Process {
        id: zenityProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (path.length > 0) root.setWallpaper(path)
            }
        }
    }

    Process {
        id: scanProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split("\n").filter(function(f) { return f.length > 0 })
                if (files.length === 0) {
                    console.warn("WallpaperService: no images or videos found in", root.wallpaperDirectory)
                    root.wallpaperPaths = []
                    return
                }
                files.sort()
                root.wallpaperPaths = files

                if (root.currentWallpaper && files.indexOf(root.currentWallpaper) !== -1) {
                    root._currentIndex = files.indexOf(root.currentWallpaper)
                } else if (files.length > 0) {
                    root._currentIndex = 0
                    root.currentWallpaper = files[0]
                    root._saveState()
                }
                root._initialized = true
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.warn("WallpaperService scan error:", text)
            }
        }
    }

    Process {
        id: saveProcess
        running: false
    }

    Process {
        id: loadProcess
        command: ["cat", root._cacheFile]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var obj = JSON.parse(text)
                    if (obj.currentWallpaper)   root.currentWallpaper   = obj.currentWallpaper
                    if (obj.wallpaperDirectory) root.wallpaperDirectory = obj.wallpaperDirectory
                } catch(e) {}
                root._scan()
            }
        }

        onExited: function(code) {
            if (code !== 0) root._scan()
        }
    }

    Timer {
        id: directoryWatcherTimer
        interval: 10000 
        running: true
        repeat: true
        onTriggered: root._scan()
    }

    Component.onCompleted: {
        loadProcess.running = true
    }
}
