import QtQuick
import QtQuick.Controls

Rectangle {
    id: btn
    width: 50
    height: 50
    radius: 12

    color: hovered ? "#2A2A2A" : "#252525"

    property alias iconSource: icon.source
    property string tooltipText: ""

    signal clicked

    property bool hovered: false

    Image {
        id: icon
        anchors.centerIn: parent
        width: 26
        height: 26
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: btn.hovered = true
        onExited: btn.hovered = false

        onClicked: btn.clicked()
    }

    ToolTip.visible: hovered
    ToolTip.text: tooltipText
}
