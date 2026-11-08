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
                PowerButton { Layout.alignment: Qt.AlignVCenter }
                Network { Layout.alignment: Qt.AlignVCenter }
                Battery { Layout.alignment: Qt.AlignVCenter }
            }

            Clock {
                anchors.centerIn: parent
            }

            RowLayout {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: 10
                }
                Workspaces {
                    screenName: barRoot.screen.name
                    Layout.alignment: Qt.AlignVCenter
                }
                WallpaperButton {
                    Layout.alignment: Qt.AlignVCenter
                }

            }
        }
        
    }
    
}
