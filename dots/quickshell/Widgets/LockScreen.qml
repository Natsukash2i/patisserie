import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

Scope {
    id: root

    property string userName: ""
    property string authErrorMessage: ""
    property int authFailCount: 0
    property date currentTime: new Date()
    property bool isLocked: false
    
    property string currentPassword: ""

    Process {
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.userName = text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    PamContext {
        id: pam
        config: "quickshell"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentPassword);
            }
        }

        onCompleted: result => {
            root.currentPassword = "";
            
            if (result === PamResult.Success) {
                root.authErrorMessage = "";
                root.isLocked = false;
            } else {
                root.authErrorMessage = "Incorrect password";
                root.authFailCount += 1;
            }
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: root.isLocked

        onLockedChanged: {
            if (locked) {
                root.authErrorMessage = "";
                root.authFailCount = 0;
            } else {
                pam.abort();
            }
        }

        WlSessionLockSurface {
            id: surface
            color: "#1D1E27"

            // Rectangle {
            //     anchors.fill: parent
            //     gradient: Gradient {
            //         GradientStop { position: 0.0; color: "#1a1f2c" }
            //         GradientStop { position: 1.0; color: "#05070c" }
            //     }
            // }

            MouseArea {
                anchors.fill: parent
                onClicked: passwordInput.forceActiveFocus()
            }

            Column {
                anchors.centerIn: parent
                spacing: 18

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(root.currentTime, "hh:mm")
                    font.pointSize: 88
                    font.weight: Font.Bold
                    font.family: "Geist"
                    color: "#D1D2E8"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(root.currentTime, "dddd, MMMM d")
                    font.pointSize: 20
                    font.weight: Font.Light
                    font.family: "Geist"
                    color: "#D1D2E8"
                }

                Item { width: 1; height: 16 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 72
                    height: 72
                    radius: 36
                    color: "#3D3D50"
                    border.color: "#3F3F52"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: root.userName.length > 0 ? root.userName.charAt(0).toUpperCase() : "?"
                        color: "#8282A9"
                        font.pointSize: 28
                        font.weight: Font.DemiBold
                        font.family: "Geist"
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.userName.length > 0 ? root.userName : "..."
                    color: "#D1D2E8"
                    font.pointSize: 16
                    font.family: "Geist"
                }

                Item { width: 1; height: 8 }

                Rectangle {
                    id: fieldBg
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 260
                    height: 46
                    radius: 23
                    color: "#1c2230"
                    border.width: 1
                    border.color: passwordInput.activeFocus ? "#8483D8" : "#333a4a"

                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: fieldBg; property: "anchors.horizontalCenterOffset"; to: -12; duration: 45 }
                        NumberAnimation { target: fieldBg; property: "anchors.horizontalCenterOffset"; to: 12; duration: 90 }
                        NumberAnimation { target: fieldBg; property: "anchors.horizontalCenterOffset"; to: -8; duration: 90 }
                        NumberAnimation { target: fieldBg; property: "anchors.horizontalCenterOffset"; to: 0; duration: 60 }
                    }

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: "#D1D2E8"
                        font.pointSize: 16
                        clip: true
                        focus: true

                        onTextChanged: root.authErrorMessage = ""

                        onAccepted: {
                            if (text === "") return;
                            root.currentPassword = text;
                            pam.start(); 
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Enter password"
                        color: "#8282A9"
                        font.pointSize: 14
                        font.family: "Geist"
                        visible: passwordInput.text.length === 0 && !passwordInput.activeFocus
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.authErrorMessage
                    color: "#ff6b6b"
                    font.pointSize: 13
                    font.family: "Geist"
                    height: 18
                    visible: root.authErrorMessage.length > 0
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 32

                Repeater {
                    model: [
                        { label: "⏻", cmd: ["systemctl", "poweroff"] },
                        { label: "⟲", cmd: ["systemctl", "reboot"] },
                        { label: "⏾", cmd: ["systemctl", "suspend"] }
                    ]

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: powerArea.containsMouse ? "#2a3040" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: "white"
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: powerArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Quickshell.execDetached(modelData.cmd)
                        }
                    }
                }
            }

            Connections {
                target: root
                function onAuthFailCountChanged() {
                    passwordInput.text = "";
                    shakeAnim.restart();
                    passwordInput.forceActiveFocus();
                }
                function onIsLockedChanged() {
                    if (root.isLocked) {
                        passwordInput.text = "";
                        passwordInput.forceActiveFocus();
                    }
                }
            }

            Component.onCompleted: passwordInput.forceActiveFocus()
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.isLocked = true; }
        function unlock(): void { root.isLocked = false; }
        function isLocked(): bool { return root.isLocked; }
    }
}
