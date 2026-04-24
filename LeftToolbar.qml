import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: 70
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    color: vcuCommunication.vcuAlive ? themeManager.dividerColor : themeManager.redColor

    // Main.qml bu sinyali dinliyor
    signal pageRequested(int index)

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        LeftToolbarButton {
            iconSource: "qrc:/resource/icons/toolbar_vehicle_icon.png"
            tooltipText: "Araç"
            onClicked: {root.pageRequested(0) ; /*loader3D.item.setWarning("uyarı");*/} // → VehiclePage
        }
        LeftToolbarButton {
            iconSource: "qrc:/resource/icons/toolbar_microphone_icon.png"
            tooltipText: "Ses Sistemi"
            onClicked: root.pageRequested(1)   // → AudioPage
        }
        LeftToolbarButton {
            iconSource: "qrc:/resource/icons/toolbar_connection_icon.png"
            tooltipText: "Bağlantı"
            onClicked: root.pageRequested(2)   // → ConnectionPage
        }
    }
}
