pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: logoutRoot

    IpcHandler {
        target: "powerMenu"
        function open(): void { logoutRoot.isActive = true }
        function close(): void { logoutRoot.isActive = false }
    }

    property bool isActive: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: logoutRoot.isActive
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

            anchors { top: true; bottom: true; left: true; right: true }
            color: "#1D1E27"
            focusable: visible

            Rectangle {
                anchors.fill: parent
                color: "#1D1E27"
                focus: true
                Keys.onEscapePressed: logoutRoot.isActive = false


                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 30

                    Text {
                        text: "Goodbye, " + (Quickshell.env("USER")) + "!"
                        color: "#D1D2E8"
                        font { family: "Geist"; pointSize: 24; bold: true }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter

                        MenuButton {
                            icon: "" 
                            label: "Power Off"
                            accentColor: "#E66D75"
                            onClicked: {
                                logoutRoot.isActive = false
                                Quickshell.execDetached(["systemctl", "poweroff"])
                            }
                        }

                        MenuButton {
                            icon: "" 
                            label: "Reboot"
                            onClicked: {
                                logoutRoot.isActive = false
                                Quickshell.execDetached(["systemctl", "reboot"])
                            }
                        }
                    }
                }
            }
        }
    }

    component MenuButton: Rectangle {
        id: btn
        property string icon: ""
        property string label: ""
        property color accentColor: "#D1D2E8"
        signal clicked()

        width: 140; height: 140; radius: 16
        color: "#1D1E27"
        border.color: "#3F3F52"
        border.width: 1

        scale: mouseArea.containsMouse ? 1.05 : 1.0

        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad }} 
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: btn.icon
                color:  btn.accentColor
                font { family: "JetBrainsMono Nerd Font"; pointSize: 32 }
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: btn.label
                color: "#D1D2E8"
                font { family: "Geist"; pointSize: 11; bold: true }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
