import QtQuick

Window {
    width: Screen.width
    height: Screen.height
    visibility: "FullScreen"


    Component.onCompleted: {
        serialReceiver.start("/tmp/ttyV1", 115200)

    }

    Connections {
        target: serialReceiver
        function onDataReceived(deg1, deg2, length, imuX, imuY) {
            console.log("Veri Geldi =>", deg1, deg2, length, imuX, imuY)
            // SOCAT İLE TEST EDEBİLRİİSN .
            loader3D.item.setAngle(loader3D.item.rightPalTransform, parseInt(deg1))
        }
    }

    Rectangle {
        id: model3D
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        Loader {
            id: loader3D
            anchors.fill: parent
            source: ""

        }

        Component.onCompleted: {
            loader3D.source = "par3DView.qml"
        }
    }
}
