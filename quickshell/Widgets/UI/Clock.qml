import Quickshell
import QtQuick

Rectangle {
    implicitWidth: clockText.implicitWidth + 20
    implicitHeight: clockText.implicitHeight + 10
    radius: implicitHeight / 3

    color: "#1D1E27"

    border {
        width: 1 
        color: "#3F3F52"
    }
    
    Text {
        id: clockText  

        SystemClock {
            id: clock 
            precision: SystemClock.Minutes
        }
        
        text: Qt.formatDateTime(clock.date, "ddd, MM-dd × hh:mm") 
        color: "#D1D2E8"

        font {
            family: "Geist"
            pointSize: 11
            weight: Font.Medium

        } 
        anchors.centerIn: parent
    }
}
