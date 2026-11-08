pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Rectangle {
    id: root

    implicitWidth: powerIcon.width + 20
    implicitHeight: 27
    radius: implicitHeight / 3

    color: "#1D1E27"

    Text {
        id: powerIcon
        text: "" 
        anchors.centerIn: parent
        color: area.containsMouse ? "#E66D75" : "#D1D2E8"
        font { 
            family: "JetBrainsMono Nerd Font" 
            pointSize: 10.5
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
