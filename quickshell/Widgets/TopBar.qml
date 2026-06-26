import Quickshell
import QtQuick.Layouts
import QtQuick
import "UI"

Variants {
    model: Quickshell.screens
    
    PanelWindow {
        id: barRoot
        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true 
            right: true
        }

        implicitHeight: 30

        color: "transparent"

        exclusionMode: ExclusionMode.Auto

        Item {
            anchors.fill: parent
            RowLayout {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    top: parent.top
                    leftMargin: 10
                }
                PowerButton {}
                Battery {}
            }

            Clock {
                anchors.centerIn: parent
            }

            RowLayout {
                anchors {
                    right: parent.right
                    rightMargin: 10
                }
                WallpaperButton {
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
        
    }
    
}
