pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts 
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property var audioSink: Pipewire.defaultAudioSink?.audio
    readonly property bool muted: audioSink ? audioSink.muted : false
    readonly property real volume: audioSink? audioSink.volume : 0.0

    property bool shouldShowOSD: false 

    function triggerOSD() {
        root.shouldShowOSD = true
        hideTimer.restart()
    } 

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null 
        function onVolumeChanged() { root.triggerOSD() } 
        function onMutedChanged() { root.triggerOSD() }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shouldShowOSD = false;
    }
    
    LazyLoader {
        active: root.shouldShowOSD

        PanelWindow {
            anchors.left: true
            margins.left: 10
            exclusiveZone: 0
            implicitWidth: 50
            implicitHeight: 250
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                
                color: "#1D1E27"
                border {
                    width: 1 
                    color: "#3F3F52"
                }
                radius: width / 3
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 12
                    }
                    spacing: 10

                    Text {
                        text: root.muted ? "MUTE" : Math.round(root.volume * 100)
                        color: "#D1D2E8"
                        font {
                            family: "Geist"
                            pointSize: 10
                            bold: true
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        implicitWidth: 10
                        radius: implicitWidth / 3
                        color: "#D1D2E8"
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            anchors {
                                left: parent.left 
                                right: parent.right
                                bottom: parent.bottom
                            }
                            height: parent.height * Math.min(1.0, root.volume)
                            radius: parent.radius
                            color: "#8483D8"

                            Rectangle {
                                width: 16
                                height: 16
                                radius: width / 2 
                                color: "#9291DC"

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.top

                            }
                        }
                    }
                        
                    IconImage {
                        implicitSize: 15
                        source: Quickshell.iconPath(root.muted ? "audio-volume-muted-symbolic" : (root.volume < 0.3 ? "audio-volume-low-symbolic" :  "audio-volume-high-symbolic"))
                        Layout.alignment: Qt.AlignHCenter
                    }

                }
            }
        }
    }
    
}
