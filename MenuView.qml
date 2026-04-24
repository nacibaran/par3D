import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    anchors.fill: parent
    color: themeManager.lightGrayColor
    radius: 8

    default property alias content: contentArea.data

    // Ortak başlık alanı
    Rectangle {
        id: header
        width: parent.width
        height: 50
        color: themeManager.dividerColor
        Text {
            id: pageTitle
            anchors.centerIn: parent
            text: root.title
            color: themeManager.lightGrayColor
            font.pixelSize: 18
            font.bold: true
        }
    }

    Item {
        id: contentArea
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
        }
    }

    // Tüm sayfalarda ortak olacak property
    property string title: "Sayfa"
}
