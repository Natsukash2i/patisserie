pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Rectangle {
    id: root

    implicitWidth: powerIcon.width + 15
    implicitHeight: powerIcon.height + 10
    radius: implicitHeight / 3

    color: "#1D1E27"
    border { width: 1; color: "#3F3F52" }

    Text {
        id: powerIcon
        text: "" 
        anchors.centerIn: parent
        color: area.containsMouse ? "#E66D75" : "#D1D2E8"
        font { 
            family: "JetBrainsMono Nerd Font" 
            pointSize: 11 
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "powerMenu", "open"])
    }
}
