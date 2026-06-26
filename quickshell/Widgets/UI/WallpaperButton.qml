pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../Services"

Rectangle {
    id: wallpaperButton

    implicitWidth: wallpaperIcon.width + 15
    implicitHeight: wallpaperIcon.height + 10
    radius: implicitHeight / 3
    
    color: "#1D1E27"
    border { width: 1; color: "#3F3F52" }

    // ── QUICKSHELL POPUP WINDOW ──
    PopupWindow {
        id: customWallpaperDialog
        visible: false
        implicitWidth: 500
        implicitHeight: 400
        
        grabFocus: true
        color: "transparent"

        anchor {
            item: wallpaperButton
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins { top: 5 } 
        }

        // Fix 1: Use a Loader to defer creation until the popup opens.
        // This ensures GridView accurately calculates its dimensions on creation.
        Loader {
            anchors.fill: parent
            active: customWallpaperDialog.visible
            onActiveChanged: {
                if (active) {
                    WallpaperService.refresh();
                }
            }
            sourceComponent: Rectangle {
                color: "#1D1E27"
                border.color: "#3F3F52"
                border.width: 1
                radius: 8
                clip: true

                GridView {
                    id: imageGrid
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    
                    cellWidth: 160
                    cellHeight: 110
                    
                    // Fix 2: Allocate extra pixel buffer space to pre-render off-screen images
                    cacheBuffer: 1000 
                    
                    model: WallpaperService.wallpaperPaths

                    delegate: Item {
                        id: delegateItem
                        width: imageGrid.cellWidth
                        height: imageGrid.cellHeight

                        required property string modelData

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "#15161D"
                            radius: 6
                            clip: true
                            border.width: 1
                            border.color: mouseArea.containsMouse ? "#D1D2E8" : "#3F3F52"

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                
                                // Fix 3: encodeURI handles spaces (' ') and special characters in paths safely
                                source: "file://" + encodeURI(delegateItem.modelData) 
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true 
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    console.log("Selected file path:", delegateItem.modelData) 
                                    WallpaperService.setWallpaper(delegateItem.modelData)
                                    customWallpaperDialog.visible = false
                                }
                            }
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "No wallpapers found"
                    color: "#5C5E72"
                    font.pointSize: 11
                    visible: WallpaperService.wallpaperPaths.length === 0
                }
            }
        }
    }

    Text {
        id: wallpaperIcon
        anchors.centerIn: parent
        text: ""
        color: "#D1D2E8"
        font { family: "JetBrainsMono Nerd Font"; pointSize: 11 }
    }
    
    MouseArea {
        id: wallpaperButtonArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: customWallpaperDialog.visible = !customWallpaperDialog.visible
    }
}
