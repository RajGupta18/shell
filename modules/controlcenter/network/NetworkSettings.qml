pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    SectionHeader {
        Layout.topMargin: Appearance.spacing.large
        title: qsTr("Wireless")
        description: qsTr("WiFi network settings")
    }

    SectionContainer {
        ToggleRow {
            label: qsTr("WiFi enabled")
            checked: Network.wifiEnabled
            toggle.onToggled: {
                Network.enableWifi(checked);
            }
        }
    }

    SectionHeader {
        Layout.topMargin: Appearance.spacing.large
        title: qsTr("Current connection")
        description: qsTr("Active network connection information")
    }

    SectionContainer {
        contentSpacing: Appearance.spacing.small / 2

        PropertyRow {
            label: qsTr("Network")
            value: Network.active ? Network.active.ssid : qsTr("Not connected")
        }

        PropertyRow {
            showTopMargin: true
            visible: Network.active !== null
            label: qsTr("Signal strength")
            value: Network.active ? qsTr("%1%").arg(Network.active.strength) : qsTr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            visible: Network.active !== null
            label: qsTr("Security")
            value: Network.active ? (Network.active.isSecure ? qsTr("Secured") : qsTr("Open")) : qsTr("N/A")
        }

        PropertyRow {
            showTopMargin: true
            visible: Network.active !== null
            label: qsTr("Frequency")
            value: Network.active ? qsTr("%1 MHz").arg(Network.active.frequency) : qsTr("N/A")
        }
    }
}

