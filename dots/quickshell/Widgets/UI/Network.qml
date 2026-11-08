import Quickshell
import QtQuick
import Quickshell.Networking

Rectangle {
    id: networkRoot

    implicitWidth: wifiIcon.width + 20
    implicitHeight: 27
    radius: implicitHeight / 3
    color: "#1D1E27"

    readonly property int state: Networking.connectivity

    function getWifiIcon(stat) {
        switch (stat) {
            case NetworkConnectivity.Full:
                return "󰤨"
            case NetworkConnectivity.Limited:
                return "󰤫"
            case NetworkConnectivity.Portal:
                return "󰤵"
            case NetworkConnectivity.None:
            default:
                return "󰤮"
        }
    }

    Text {
        id: wifiIcon
        anchors.centerIn: parent
        text: getWifiIcon(networkRoot.state)
        
        color: networkRoot.state === NetworkConnectivity.Full ? "#68C74F" : "#FF5555"
        
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
        onClicked: Quickshell.execDetached(["nmgui"])
    }
}
