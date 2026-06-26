pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "Services"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaperWin
            required property var modelData

            anchors { top: true; bottom: true; left: true; right: true }

            WlrLayershell.layer:   WlrLayer.Background
            WlrLayershell.namespace: "quickshell:wallpaper"
            WlrLayershell.screen:  modelData

            exclusiveZone: -1
            focusable:     false
            color:         "transparent"

            property bool imageError: false

            Connections {
                target: WallpaperService
                function onCurrentWallpaperChanged() { wallpaperWin.imageError = false }
            }

            Image {
                anchors.fill: parent
                fillMode:     Image.PreserveAspectCrop
                asynchronous: true
                cache:        false
                sourceSize.width:  wallpaperWin.width
                sourceSize.height: wallpaperWin.height

                source: wallpaperWin.imageError ? "" : WallpaperService.currentWallpaper
                        ? "file://" + WallpaperService.currentWallpaper : ""

                opacity: status === Image.Ready ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
                }

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("Wallpaper failed to load:", source)
                        wallpaperWin.imageError = true
                    }
                }
            }
        }
    }
}
