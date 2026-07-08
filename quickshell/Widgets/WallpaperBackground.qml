pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import QtMultimedia
import "Services"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaperWin
            required property var modelData

            anchors { top: true; bottom: true; left: true; right: true }

            WlrLayershell.layer:     WlrLayer.Background
            WlrLayershell.namespace: "quickshell:wallpaper"
            WlrLayershell.screen:    modelData

            exclusiveZone: -1
            focusable:      false
            color:          "transparent"

            property bool imageError: false
            
            // Detect if the file is a video based on its extension
            property bool isVideo: {
                var path = WallpaperService.currentWallpaper
                if (!path || imageError) return false
                var ext = path.split('.').pop().toLowerCase()
                return ["mp4", "webm", "mkv", "mov", "avi"].indexOf(ext) !== -1
            }

            Connections {
                target: WallpaperService
                function onCurrentWallpaperChanged() { 
                    wallpaperWin.imageError = false 
                    if (wallpaperWin.isVideo) {
                        player.play()
                    }
                }
            }

            // ── Static Image Layer ───────────────────────────────────────────
            Image {
                anchors.fill: parent
                fillMode:     Image.PreserveAspectCrop
                asynchronous: true
                cache:        false
                sourceSize.width:  wallpaperWin.width
                sourceSize.height: wallpaperWin.height

                source: (!wallpaperWin.imageError && !wallpaperWin.isVideo && WallpaperService.currentWallpaper)
                        ? "file://" + WallpaperService.currentWallpaper : ""

                visible: !wallpaperWin.isVideo
                opacity: (status === Image.Ready && !wallpaperWin.isVideo) ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
                }

                onStatusChanged: {
                    if (status === Image.Error && !wallpaperWin.isVideo) {
                        console.log("Wallpaper failed to load:", source)
                        wallpaperWin.imageError = true
                    }
                }
            }

            // ── Video Layer ──────────────────────────────────────────────────
            MediaPlayer {
                id: player
                // Omit AudioOutput entirely so videos play silently without wasting resources
                source: (wallpaperWin.isVideo && !wallpaperWin.imageError) ? "file://" + WallpaperService.currentWallpaper : ""
                videoOutput: videoOutput
                loops: MediaPlayer.Infinite

                onSourceChanged: {
                    if (source !== "") {
                        player.play()
                    }
                }
            }

            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
                visible: wallpaperWin.isVideo
                
                // Fade in smoothly when the video actually starts playing
                opacity: (player.playbackState === MediaPlayer.PlayingState && wallpaperWin.isVideo) ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
