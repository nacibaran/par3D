import QtQuick
import QtQuick.Controls

Window {
    width: Screen.width
    height: Screen.height
    visibility: "FullScreen"

    // Aktif sayfa takibi
    property int currentPage: 0

    LeftToolbar {
        id: leftBar
        onPageRequested: (index) => currentPage = index
    }

    // Orta alan — sayfa loader
    Loader {
        id: pageLoader
        anchors {
            left: leftBar.right
            right: model3D.left
            top: parent.top
            bottom: parent.bottom
        }

        source: {
            switch(currentPage) {
                case 0: return "VehiclePage.qml"
                case 1: return "AudioPage.qml"
                case 2: return "ConnectionPage.qml"
                default: return "VehiclePage.qml"
            }
        }
    }

    // 3D model — sabit sağda
    Rectangle {
        id: model3D
        width: parent.width / 2
        height: parent.height
        anchors.right: parent.right

        Loader {
            id: loader3D
            anchors.fill: parent
            source: "Hancer3DView.qml"
        }
    }
}
