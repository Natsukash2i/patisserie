import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../Services"

Rectangle { id: root

    required property string screenName

    property color colorBg: "#1D1E27"
    property color colorFocused: "#8483D8"
    property color colorOnFocused: "#1D1E27"
    property color colorOccupied: "#BB83D8"
    property color colorEmpty: "#3F3F52"
    property color colorText: "#D1D2E8"
    property color colorUrgent: "#E66D75"
    property bool showEmptyTags: false

    readonly property var monData: MangoService.monitors[screenName]
    readonly property var tagList: monData ? monData.tags : []
    readonly property var visibleTags: tagList.filter(t => root.showEmptyTags || t.clients > 0 || t.focused || t.urgent)

    color: colorBg
    radius: height / 3
    implicitHeight: 27
    implicitWidth: row.implicitWidth + 20

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 6

        spacing: 4

        Repeater {
            model: root.visibleTags

            delegate: Rectangle {
                id: pill
                required property var modelData
                readonly property bool focused: modelData.focused
                readonly property bool urgent: modelData.urgent
                readonly property bool occupied: modelData.clients > 0

                Layout.alignment: Qt.AlignVCenter
                width: 20
                height: 16
                radius: width / 3

                color: urgent ? root.colorUrgent
                     : focused ? root.colorFocused
                     : "transparent"

                border.width: focused ? 0 : 1
                border.color: occupied ? root.colorOccupied : root.colorEmpty

                scale: mouseArea.pressed ? 0.9 : (focused ? 1.1 : (mouseArea.containsMouse ? 1.05 : 1.0))

                Behavior on scale {
                    NumberAnimation { duration: 140; easing.type: Easing.OutBack; easing.overshoot: 3 }
                }
                Behavior on color { ColorAnimation { duration: 160 } }
                Behavior on border.color { ColorAnimation { duration: 160 } }

                SequentialAnimation on opacity {
                    running: pill.urgent
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 420; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 420; easing.type: Easing.InOutQuad }
                }

                Text {
                    anchors.centerIn: parent
                    text: pill.modelData.id
                    color: pill.focused ? root.colorOnFocused : (pill.occupied ? root.colorText : root.colorEmpty)
                    font.pointSize: 8
                    font.bold: pill.focused
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MangoService.viewTag(root.screenName, pill.modelData.id)
                }
            }
        }

        Item { 
            Layout.fillWidth: true
            Layout.alignment:Qt.AlignVCenter
            Text {
                readonly property var activeToplevel: ToplevelManager.activeToplevel
                text: activeToplevel ? "" : ""
                color: root.colorText
                anchors.centerIn: parent
                font.family: "JetBrainsMono Nerd Font"
                font.pointSize: 8
            }
        }

        Text {
            Layout.maximumWidth: 100
            Layout.alignment: Qt.AlignVCenter
            readonly property var activeToplevel: ToplevelManager.activeToplevel
            visible: text.length > 0
            elide: Text.ElideRight
            color: root.colorText
            font.pointSize: 9
            font.family: "Geist"
            text: activeToplevel ? (activeToplevel.title || "") : ""
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => {
            if (event.angleDelta.y < 0) MangoService.viewNext(root.screenName, false);
            else if (event.angleDelta.y > 0) MangoService.viewPrev(root.screenName, false);
        }
    }
}
