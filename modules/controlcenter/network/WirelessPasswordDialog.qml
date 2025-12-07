pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    readonly property var network: {
        if (session.network.active) {
            return session.network.active;
        }
        return null;
    }

    property bool isOpened: false
    visible: Network.isconnectionFailed || root.isOpened
    enabled: true
    focus: true

    onVisibleChanged: {
        if(root.visible)
        {
            if(isOpened === false)
            {
                isOpened = true;
            }
            passwordContainer.forceActiveFocus();
            passwordContainer.passwordBuffer = "";
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: root.visible ? 1 : 0

        Behavior on opacity {
            Anim {}
        }

        MouseArea {
            anchors.fill: parent
            onClicked: closeDialog()
        }
    }

    StyledRect {
        id: dialog

        anchors.centerIn: parent

        implicitWidth: 400
        implicitHeight: content.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surface
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.7

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {}
        }

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.normal

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "lock"
                font.pointSize: Appearance.font.size.extraLarge * 2
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enter password")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: root.network ? qsTr("Network: %1").arg(root.network.ssid) : ""
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                id: statusText

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Appearance.spacing.small
                visible: connectButton.connecting || connectButton.hasError
                text: {
                    if (connectButton.hasError) {
                        return qsTr("Connection failed. Please check your password and try again.");
                    }
                    if (connectButton.connecting) {
                        return qsTr("Connecting...");
                    }
                    return "";
                }
                color: connectButton.hasError ? Colours.palette.m3error : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                font.weight: 400
                wrapMode: Text.WordWrap
                Layout.maximumWidth: parent.width - Appearance.padding.large * 2
            }

            Item {
                id: passwordContainer
                Layout.topMargin: Appearance.spacing.large
                Layout.fillWidth: true
                implicitHeight: Math.max(48, charList.implicitHeight + Appearance.padding.normal * 2)

                focus: true
                clip: true
                Keys.onPressed: event => {
                    if (!activeFocus) {
                        forceActiveFocus();
                    }

                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        if (connectButton.enabled) {
                            connectButton.clicked();
                        }
                        event.accepted = true;
                    }
                    else if(event.key === Qt.Key_Escape)
                    {
                        event.accepted = true;
                        root.closeDialog();
                    } 
                    else if (event.key === Qt.Key_Backspace) {
                        if (event.modifiers & Qt.ControlModifier) {
                            passwordBuffer = "";
                        } else {
                            passwordBuffer = passwordBuffer.slice(0, -1);
                        }
                        event.accepted = true;
                    }
                    else if (event.text && event.text.length > 0) {
                        passwordBuffer += event.text;
                        event.accepted = true;
                    }
                    console.info(passwordBuffer)
                }

                property string passwordBuffer: ""

                StyledRect {
                    anchors.fill: parent
                    radius: Appearance.rounding.normal
                    color: passwordContainer.activeFocus ? Qt.lighter(Colours.tPalette.m3surfaceContainer, 1.05) : Colours.tPalette.m3surfaceContainer
                    border.width: passwordContainer.activeFocus || connectButton.hasError ? 4 : (root.visible ? 1 : 0)
                    border.color: {
                        if (connectButton.hasError) {
                            return Colours.palette.m3error;
                        }
                        if (passwordContainer.activeFocus) {
                            return Colours.palette.m3primary;
                        }
                        return root.visible ? Colours.palette.m3outline : "transparent";
                    }

                    Behavior on border.color {
                        CAnim {}
                    }

                    Behavior on border.width {
                        CAnim {}
                    }

                    Behavior on color {
                        CAnim {}
                    }
                }

                StateLayer {
                    hoverEnabled: false
                    cursorShape: Qt.IBeamCursor

                    function onClicked(): void {
                        passwordContainer.forceActiveFocus();
                    }
                }

                StyledText {
                    id: placeholder
                    anchors.centerIn: parent
                    text: qsTr("Password")
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.normal
                    font.family: Appearance.font.family.mono
                    opacity: passwordContainer.passwordBuffer ? 0 : 1

                    Behavior on opacity {
                        Anim {}
                    }
                }

                ListView {
                    id: charList

                    readonly property int fullWidth: count * (implicitHeight + spacing) - spacing

                    anchors.centerIn: parent
                    implicitWidth: fullWidth
                    implicitHeight: Appearance.font.size.normal

                    orientation: Qt.Horizontal
                    spacing: Appearance.spacing.small / 2
                    interactive: false

                    model: ScriptModel {
                        values: [...passwordContainer.passwordBuffer.split("")]
                    }

                    delegate: StyledRect {
                        id: ch

                        implicitWidth: implicitHeight
                        implicitHeight: charList.implicitHeight

                        color: Colours.palette.m3onSurface
                        radius: Appearance.rounding.small / 2

                        opacity: 0
                        scale: 0
                        Component.onCompleted: {
                            opacity = 1;
                            scale = 1;
                        }

                        ListView.onRemove: removeAnim.start()

                        SequentialAnimation {
                            id: removeAnim

                            PropertyAction {
                                target: ch
                                property: "ListView.delayRemove"
                                value: true
                            }
                            ParallelAnimation {
                                Anim {
                                    target: ch
                                    property: "opacity"
                                    to: 0
                                }
                                Anim {
                                    target: ch
                                    property: "scale"
                                    to: 0.5
                                }
                            }
                            PropertyAction {
                                target: ch
                                property: "ListView.delayRemove"
                                value: false
                            }
                        }

                        Behavior on opacity {
                            Anim {}
                        }

                        Behavior on scale {
                            Anim {
                                duration: Appearance.anim.durations.expressiveFastSpatial
                                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
                            }
                        }
                    }

                    Behavior on implicitWidth {
                        Anim {}
                    }
                }
            }

            RowLayout {
                Layout.topMargin: Appearance.spacing.normal
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                TextButton {
                    id: cancelButton

                    Layout.fillWidth: true
                    Layout.minimumHeight: Appearance.font.size.normal + Appearance.padding.normal * 2
                    inactiveColour: Colours.palette.m3secondaryContainer
                    inactiveOnColour: Colours.palette.m3onSecondaryContainer
                    text: qsTr("Cancel")

                    onClicked: root.closeDialog()
                }

                TextButton {
                    id: connectButton

                    property bool initialclick: false
                    property bool connecting: Network.isconnectionFailed === false && root.isOpened === true && connectButton.initialclick === true
                    property bool hasError: connectButton.initialclick === true && connectButton.connecting === false

                    Layout.fillWidth: true
                    Layout.minimumHeight: Appearance.font.size.normal + Appearance.padding.normal * 2
                    inactiveColour: Colours.palette.m3primary
                    inactiveOnColour: Colours.palette.m3onPrimary
                    text: !connecting ? qsTr("Connect"): qsTr("Connecting...")
                    enabled: passwordContainer.passwordBuffer.length > 0 && !connecting

                    onClicked: {
                        if (!root.network || connecting) {
                            return;
                        }
                        const password = passwordContainer.passwordBuffer;
                        if (!password || password.length === 0) {
                            return;
                        }
                        Network.connectToSecureNetwork(root.network.ssid, password);
                        passwordContainer.passwordBuffer = "";
                        if(initialclick === false)
                        {
                            initialclick = true;
                        }
                    }

                    Connections {
                        target: Network
                        function onIsnetworkconnectedChanged() {
                            if(Network.isnetworkconnected === true && root.visible)
                            {
                                root.closeDialog();
                            }
                        }
                    }
                }
            }
        }
    }

    function closeDialog(): void {
        isOpened = false;
        Network.isconnectionFailed = false;
        passwordContainer.passwordBuffer = "";
        connectButton.connecting = false;
        connectButton.text = qsTr("Connect");
        connectButton.initialclick = false;
    }
}
