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

        // FIX: Removed the Loader entirely. The popup content now initializes
        // at shell startup and stays warm in memory for instant access.
        Rectangle {
            anchors.fill: parent
            color: "#1D1E27"
            border.color: "#3F3F52"
            border.width: 1
            radius: 8
            clip: true

            // ── POPUP HEADER ──
            Item {
                id: popupHeader
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 40

                Text {
                    text: "Wallpapers"
                    color: "#D1D2E8"
                    anchors { left: parent.left; leftMargin: 15; verticalCenter: parent.verticalCenter }
                    font { bold: true; pointSize: 11; family: "JetBrainsMono Nerd Font" }
                }

                // Manual Refresh Button
                Rectangle {
                    id: refreshButton
                    width: 28; height: 28
                    radius: 6
                    color: refreshMouse.containsMouse ? "#2A2B3D" : "transparent"
                    anchors { right: parent.right; rightMargin: 15; verticalCenter: parent.verticalCenter }

                    Text {
                        id: refreshIcon
                        text: "󰑐"
                        font { family: "JetBrainsMono Nerd Font"; pointSize: 12 }
                        color: refreshMouse.containsMouse ? "#FFFFFF" : "#A5A6C4"
                        anchors.centerIn: parent

                        RotationAnimator on rotation {
                            id: spinAnim
                            from: 0; to: 360; duration: 400; running: false
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            spinAnim.start()
                            WallpaperService.refresh()
                        }
                    }
                }
            }

            // ── SEPARATOR LINE ──
            Rectangle {
                id: separator
                anchors { top: popupHeader.bottom; left: parent.left; right: parent.right }
                height: 1
                color: "#2A2B3D"
            }

            // ── WALLPAPER GRID VIEW ──
            GridView {
                id: imageGrid
                anchors { top: separator.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
                anchors.margins: 10
                clip: true
                
                cellWidth: 160
                cellHeight: 110
                
                // Increased cache buffer slightly so more rows stay loaded in the background
                cacheBuffer: 880 
                
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
                        border.color: gridMouse.containsMouse ? "#D1D2E8" : "#3F3F52"

                        readonly property bool isVideoFile: {
                            var ext = delegateItem.modelData.split('.').pop().toLowerCase()
                            return ["mp4", "webm", "mkv", "mov", "avi"].indexOf(ext) !== -1
                        }

                        // Static Image Thumbnail
                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            
                            sourceSize.width: 150
                            sourceSize.height: 100
                            
                            // Explicitly set cache to true so once loaded, it stays loaded
                            cache: true
                            
                            source: parent.isVideoFile ? "" : "file://" + encodeURI(delegateItem.modelData) 
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true 
                            visible: !parent.isVideoFile
                        }

                        // Video File Placeholder
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            visible: parent.isVideoFile

                            Text {
                                text: "󰕧"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 22 }
                                color: gridMouse.containsMouse ? "#D1D2E8" : "#5C5E72"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: delegateItem.modelData.split('/').pop()
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 7 }
                                color: "#5C5E72"
                                width: 130
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            id: gridMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
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
