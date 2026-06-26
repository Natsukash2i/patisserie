import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: batteryCard
    
    implicitWidth: mainLayout.implicitWidth + 16 
    implicitHeight: mainLayout.implicitHeight + 10
    radius: implicitHeight / 3

    color: "#1D1E27"
    border.color: "#3F3F52"
    border.width: 1

    readonly property var device: UPower.displayDevice
    readonly property int percentage: device ? Math.round(device.percentage * 100) : 0
    readonly property int stat: device ? device.state : UPowerDeviceState.Unknown

    function getBatteryIcon(pct, isOnBattery) {
        if (isOnBattery) {
            if (pct >= 100) return "󰁹"
            else if (pct > 90) return "󰂂"
            else if (pct > 80) return "󰂁"
            else if (pct > 70) return "󰂀"
            else if (pct > 60) return "󰁿"
            else if (pct > 50) return "󰁾"
            else if (pct > 40) return "󰁽"
            else if (pct > 30) return "󰁼"
            else if (pct > 20) return "󰁻"
            else return "󰁺"
        } else {
            if (pct >= 100) return "󰂅"
            else if (pct > 90) return "󰂋"
            else if (pct > 80) return "󰂊"
            else if (pct > 70) return "󰢞"
            else if (pct > 60) return "󰂉"
            else if (pct > 50) return "󰢝"
            else if (pct > 40) return "󰂈"
            else if (pct > 30) return "󰂇"
            else if (pct > 20) return "󰂆"
            else return "󰢜"
        }
    }

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: iconText
            text: batteryCard.getBatteryIcon(batteryCard.percentage, UPower.onBattery) 
            color: "#68C74F"
            font {
                family: "JetBrainsMono Nerd Font"
                pointSize: 11 
            }   
        }


        Text {
            id: percentageText
            text: batteryCard.percentage + "%"
            color: "#D1D2E8"
            font {
                family: "Geist"
                pointSize: 10
                bold: true
            }
            
            Layout.alignment: Qt.AlignBaseline
        }
    }
}
