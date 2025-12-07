pragma ComponentBehavior: Bound

import ".."
import "../components"
import "."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

DeviceDetails {
    id: root

    required property Session session
    readonly property var network: root.session.network.active

    headerComponent: Component {
        ConnectionHeader {
            icon: root.network?.isSecure ? "lock" : "wifi"
            title: root.network?.ssid ?? qsTr("Unknown")
        }
    }

    sections: [
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeader {
                    title: qsTr("Connection status")
                    description: qsTr("Connection settings for this network")
                }

                SectionContainer {
                    ToggleRow {
                        label: qsTr("Connected")
                        checked: root.network?.active ?? false
                        toggle.onToggled: {
                            if (checked) {
                                Network.connectToNetwork(root.network.ssid);
                            } else {
                                Network.disconnectFromNetwork();
                            }
                        }
                    }

                    TextButton {
                        Layout.fillWidth: true
                        Layout.topMargin: Appearance.spacing.normal
                        Layout.minimumHeight: Appearance.font.size.normal + Appearance.padding.normal * 2
                        visible: {
                            if (!root.network || !root.network.ssid) {
                                return false;
                            }
                            return Network.hasSavedProfile(root.network.ssid);
                        }
                        inactiveColour: Colours.palette.m3secondaryContainer
                        inactiveOnColour: Colours.palette.m3onSecondaryContainer
                        text: qsTr("Forget Network")

                        onClicked: {
                            if (root.network && root.network.ssid) {
                                if (root.network.active) {
                                    Network.disconnectFromNetwork();
                                }
                                Network.deleteNetwork(root.network.ssid);
                            }
                        }
                    }
                }
            }
        },
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeader {
                    title: qsTr("Network properties")
                    description: qsTr("Additional information")
                }

                SectionContainer {
                    contentSpacing: Appearance.spacing.small / 2

                    PropertyRow {
                        label: qsTr("SSID")
                        value: root.network?.ssid ?? qsTr("Unknown")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: qsTr("BSSID")
                        value: root.network?.bssid ?? qsTr("Unknown")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: qsTr("Signal strength")
                        value: root.network ? qsTr("%1%").arg(root.network.strength) : qsTr("N/A")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: qsTr("Frequency")
                        value: root.network ? qsTr("%1 MHz").arg(root.network.frequency) : qsTr("N/A")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: qsTr("Security")
                        value: root.network ? (root.network.isSecure ? root.network.security : qsTr("Open")) : qsTr("N/A")
                    }
                }
            }
        }
    ]
}
