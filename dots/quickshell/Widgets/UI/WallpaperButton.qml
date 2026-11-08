pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import "../Services"

Rectangle {
    id: wallpaperButton

    implicitWidth: wallpaperIcon.width + 20
    implicitHeight: 27
    radius: implicitHeight / 3

    color: "#1D1E27"

    function isVideoPath(path) {
        var ext = path.split('.').pop().toLowerCase()
        return ["mp4", "webm", "mkv", "mov", "avi"].indexOf(ext) !== -1
    }

    function shQuote(str) {
        return "'" + String(str).replace(/'/g, "'\\''") + "'"
    }

    function thumbCacheName(path) {
        return path.replace(/[^A-Za-z0-9]/g, "_") + ".jpg"
    }

    PopupWindow {
        id: customWallpaperDialog
        visible: false
        implicitWidth: 880
        implicitHeight: 620

        grabFocus: true
        color: "transparent"

        anchor {
            item: wallpaperButton
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins { top: 8 }
        }

        Rectangle {
            id: panelCard
            anchors.fill: parent
            color: "#1D1E27"
            border.color: "#3F3F52"
            border.width: 1
            radius: 12
            clip: true
            focus: true

            opacity: customWallpaperDialog.visible ? 1 : 0
            scale: customWallpaperDialog.visible ? 1.0 : 0.97
            transformOrigin: Item.TopLeft
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            Keys.onEscapePressed: customWallpaperDialog.visible = false

            property string searchText: ""
            property string filterMode: "all" 

            property var filteredPaths: {
                var paths = WallpaperService.wallpaperPaths || []
                var q = searchText.toLowerCase()
                return paths.filter(function (p) {
                    var name = p.split('/').pop().toLowerCase()
                    if (q.length > 0 && name.indexOf(q) === -1)
                        return false
                    var video = wallpaperButton.isVideoPath(p)
                    if (filterMode === "image" && video) return false
                    if (filterMode === "video" && !video) return false
                    return true
                })
            }

            readonly property string currentWallpaperPath: {
                if (typeof WallpaperService.currentWallpaper !== "undefined")
                    return WallpaperService.currentWallpaper
                return ""
            }

            // ── HEADER ──
            Column {
                id: header
                anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 14; leftMargin: 16; rightMargin: 16 }
                spacing: 10

                Item {
                    width: parent.width
                    height: 28

                    Column {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        spacing: 2

                        Text {
                            text: "Wallpapers"
                            color: "#D1D2E8"
                            font { bold: true; pointSize: 12; family: "JetBrainsMono Nerd Font" }
                        }
                        Text {
                            text: panelCard.filteredPaths.length + (panelCard.filteredPaths.length === 1 ? " wallpaper" : " wallpapers")
                            color: "#5C5E72"
                            font { pointSize: 8; family: "JetBrainsMono Nerd Font" }
                        }
                    }

                    Row {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        spacing: 8

                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: browseMouse.containsMouse ? "#2A2B3D" : "transparent"
                            Text {
                                text: "󰉋"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 12 }
                                color: browseMouse.containsMouse ? "#FFFFFF" : "#A5A6C4"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: browseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!browseProc.running)
                                        browseProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            id: refreshButton
                            width: 28; height: 28
                            radius: 6
                            color: refreshMouse.containsMouse ? "#2A2B3D" : "transparent"

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

                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: closeMouse.containsMouse ? "#2A2B3D" : "transparent"
                            Text {
                                text: ""
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 11 }
                                color: closeMouse.containsMouse ? "#FFFFFF" : "#A5A6C4"
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: customWallpaperDialog.visible = false
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 36

                    Rectangle {
                        id: searchBox
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; right: filterChips.left; rightMargin: 10 }
                        height: 36
                        radius: 8
                        color: "#15161D"
                        border.width: 1
                        border.color: searchField.activeFocus ? "#D1D2E8" : "#3F3F52"

                        Text {
                            id: searchIcon
                            text: ""
                            color: "#5C5E72"
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            font { family: "JetBrainsMono Nerd Font"; pointSize: 10 }
                        }

                        TextInput {
                            id: searchField
                            anchors { left: searchIcon.right; leftMargin: 8; right: clearBtn.left; rightMargin: 6; verticalCenter: parent.verticalCenter }
                            color: "#D1D2E8"
                            font { family: "JetBrainsMono Nerd Font"; pointSize: 10 }
                            clip: true
                            selectByMouse: true
                            onTextChanged: panelCard.searchText = text
                            Keys.onEscapePressed: customWallpaperDialog.visible = false
                        }

                        Text {
                            text: "Search wallpapers…"
                            color: "#5C5E72"
                            anchors.fill: searchField
                            verticalAlignment: Text.AlignVCenter
                            font: searchField.font
                            visible: searchField.text.length === 0
                        }

                        Rectangle {
                            id: clearBtn
                            width: 20; height: 20; radius: 10
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            visible: searchField.text.length > 0
                            color: clearMouse.containsMouse ? "#2A2B3D" : "transparent"
                            Text {
                                text: ""
                                anchors.centerIn: parent
                                color: "#A5A6C4"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 8 }
                            }
                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: searchField.text = ""
                            }
                        }
                    }

                    Row {
                        id: filterChips
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        spacing: 6

                        Rectangle {
                            width: chipLabelAll.width + 18; height: 28; radius: 14
                            color: panelCard.filterMode === "all" ? "#2A2B3D" : (chipMouseAll.containsMouse ? "#20212C" : "transparent")
                            border.width: 1
                            border.color: panelCard.filterMode === "all" ? "#D1D2E8" : "#3F3F52"
                            Text {
                                id: chipLabelAll
                                text: "All"
                                anchors.centerIn: parent
                                color: panelCard.filterMode === "all" ? "#D1D2E8" : "#A5A6C4"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 9 }
                            }
                            MouseArea {
                                id: chipMouseAll
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panelCard.filterMode = "all"
                            }
                        }

                        Rectangle {
                            width: chipLabelImages.width + 18; height: 28; radius: 14
                            color: panelCard.filterMode === "image" ? "#2A2B3D" : (chipMouseImages.containsMouse ? "#20212C" : "transparent")
                            border.width: 1
                            border.color: panelCard.filterMode === "image" ? "#D1D2E8" : "#3F3F52"
                            Text {
                                id: chipLabelImages
                                text: "Images"
                                anchors.centerIn: parent
                                color: panelCard.filterMode === "image" ? "#D1D2E8" : "#A5A6C4"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 9 }
                            }
                            MouseArea {
                                id: chipMouseImages
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panelCard.filterMode = "image"
                            }
                        }

                        Rectangle {
                            width: chipLabelVideos.width + 18; height: 28; radius: 14
                            color: panelCard.filterMode === "video" ? "#2A2B3D" : (chipMouseVideos.containsMouse ? "#20212C" : "transparent")
                            border.width: 1
                            border.color: panelCard.filterMode === "video" ? "#D1D2E8" : "#3F3F52"
                            Text {
                                id: chipLabelVideos
                                text: "Videos"
                                anchors.centerIn: parent
                                color: panelCard.filterMode === "video" ? "#D1D2E8" : "#A5A6C4"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 9 }
                            }
                            MouseArea {
                                id: chipMouseVideos
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panelCard.filterMode = "video"
                            }
                        }
                    }
                }
            }

            // ── SEPARATOR ──
            Rectangle {
                id: separator
                anchors { top: header.bottom; topMargin: 14; left: parent.left; right: parent.right }
                height: 1
                color: "#2A2B3D"
            }

            // ── WALLPAPER GRID ──
            GridView {
                id: imageGrid
                anchors {
                    top: separator.bottom; topMargin: 10
                    bottom: parent.bottom; bottomMargin: 16
                    left: parent.left; leftMargin: 16
                    right: parent.right; rightMargin: 26
                }
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                cellWidth: 200
                cellHeight: 140
                cacheBuffer: 1000

                model: panelCard.filteredPaths

                delegate: Item {
                    id: delegateItem
                    width: imageGrid.cellWidth
                    height: imageGrid.cellHeight

                    required property string modelData
                    readonly property bool isVideoFile: wallpaperButton.isVideoPath(delegateItem.modelData)
                    readonly property bool isSelected: panelCard.currentWallpaperPath.length > 0
                        && delegateItem.modelData === panelCard.currentWallpaperPath
                    property string thumbPath: ""

                    Component.onCompleted: {
                        if (delegateItem.isVideoFile)
                            thumbProc.running = true
                    }

                    Process {
                        id: thumbProc
                        running: false
                        command: ["sh", "-c",
                            "mkdir -p ~/.cache/quickshell/wallpaper-thumbs; " +
                            "THUMB=~/.cache/quickshell/wallpaper-thumbs/" + wallpaperButton.thumbCacheName(delegateItem.modelData) + "; " +
                            "[ -f \"$THUMB\" ] || ffmpeg -y -ss 00:00:01 -i " + wallpaperButton.shQuote(delegateItem.modelData) +
                            " -frames:v 1 -vf scale=320:-1 \"$THUMB\" >/dev/null 2>&1; " +
                            "[ -f \"$THUMB\" ] && echo \"$THUMB\""
                        ]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                var out = this.text.trim()
                                if (out.length > 0)
                                    delegateItem.thumbPath = out
                            }
                        }
                    }

                    Rectangle {
                        id: thumb
                        anchors.fill: parent
                        anchors.margins: 6
                        color: "#15161D"
                        radius: 8
                        clip: true
                        border.width: (gridMouse.containsMouse || delegateItem.isSelected) ? 2 : 1
                        border.color: delegateItem.isSelected ? "#D1D2E8" : (gridMouse.containsMouse ? "#D1D2E8" : "#3F3F52")

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1

                            sourceSize.width: 200
                            sourceSize.height: 130

                            cache: true

                            source: {
                                if (delegateItem.isVideoFile)
                                    return delegateItem.thumbPath.length > 0 ? ("file://" + encodeURI(delegateItem.thumbPath)) : ""
                                return "file://" + encodeURI(delegateItem.modelData)
                            }
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: !delegateItem.isVideoFile || delegateItem.thumbPath.length > 0
                        }

                        // fallback while the frame is being extracted (or ffmpeg is missing)
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            visible: delegateItem.isVideoFile && delegateItem.thumbPath.length === 0

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
                                width: 160
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        // video badge once a frame thumbnail is showing
                        Rectangle {
                            visible: delegateItem.isVideoFile && delegateItem.thumbPath.length > 0
                            width: 22; height: 22; radius: 6
                            color: "#00000099"
                            anchors { top: parent.top; left: parent.left; margins: 6 }
                            Text {
                                text: "󰕧"
                                anchors.centerIn: parent
                                color: "#FFFFFF"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 9 }
                            }
                        }

                        // hover filename overlay
                        Rectangle {
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                            height: 26
                            color: "#000000"
                            opacity: gridMouse.containsMouse ? 0.55 : 0
                            Behavior on opacity { NumberAnimation { duration: 120 } }

                            Text {
                                anchors { fill: parent; margins: 6 }
                                text: delegateItem.modelData.split('/').pop()
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 7 }
                                opacity: gridMouse.containsMouse ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                            }
                        }

                        // selected badge
                        Rectangle {
                            visible: delegateItem.isSelected
                            width: 20; height: 20; radius: 10
                            color: "#D1D2E8"
                            anchors { top: parent.top; right: parent.right; margins: 6 }
                            Text {
                                text: ""
                                anchors.centerIn: parent
                                color: "#1D1E27"
                                font { family: "JetBrainsMono Nerd Font"; pointSize: 8 }
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

            // custom scrollbar
            Rectangle {
                id: scrollTrack
                width: 4
                radius: 2
                color: "#2A2B3D"
                anchors { left: imageGrid.right; leftMargin: 8; top: imageGrid.top; bottom: imageGrid.bottom }
                visible: imageGrid.contentHeight > imageGrid.height

                Rectangle {
                    width: 4
                    radius: 2
                    color: "#5C5E72"
                    y: imageGrid.contentHeight > 0 ? (imageGrid.contentY / imageGrid.contentHeight) * parent.height : 0
                    height: imageGrid.contentHeight > 0
                        ? Math.max(24, (imageGrid.height / imageGrid.contentHeight) * parent.height)
                        : parent.height
                }
            }

            Text {
                anchors.centerIn: imageGrid
                text: WallpaperService.wallpaperPaths.length === 0
                    ? "No wallpapers found"
                    : "No matches for \u201c" + panelCard.searchText + "\u201d"
                color: "#5C5E72"
                font.pointSize: 11
                visible: panelCard.filteredPaths.length === 0
            }
        }

        Process {
            id: browseProc
            running: false
            command: ["zenity", "--file-selection", "--title=Choose a wallpaper",
                "--file-filter=Images and videos | *.png *.jpg *.jpeg *.webp *.bmp *.mp4 *.webm *.mkv *.mov *.avi"]
            stdout: StdioCollector {
                onStreamFinished: {
                    var path = this.text.trim()
                    if (path.length > 0) {
                        WallpaperService.setWallpaper(path)
                        customWallpaperDialog.visible = false
                    }
                }
            }
        }
    }

    Text {
        id: wallpaperIcon
        anchors.centerIn: parent
        text: "󰸉"
        color: "#D1D2E8"
        font { family: "JetBrainsMono Nerd Font"; pointSize: 11 }
    }

    MouseArea {
        id: wallpaperButtonArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            customWallpaperDialog.visible = !customWallpaperDialog.visible
            if (customWallpaperDialog.visible)
                searchField.forceActiveFocus()
        }
    }
}
