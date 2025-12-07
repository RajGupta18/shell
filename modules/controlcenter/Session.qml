import "state"
import QtQuick

QtObject {
    readonly property list<string> panes: PaneList.labels

    required property var root
    property string active: panes[0]
    property int activeIndex: 0
    property bool navExpanded: false

    readonly property BluetoothState bt: BluetoothState {}
    readonly property NetworkState network: NetworkState {}

    onActiveChanged: activeIndex = panes.indexOf(active)
    onActiveIndexChanged: active = panes[activeIndex]
}
