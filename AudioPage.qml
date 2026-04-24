import QtQuick
import QtQuick.Controls

MenuView {
    title: "Ses Sistemi"

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text { text: "Ses Seviyesi"; color: "white" }
        Slider { width: 200; from: 0; to: 100; value: 50 }
    }
}
