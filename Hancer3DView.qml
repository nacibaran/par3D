import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Extras 2.15


Base3DView {
    id: enhanced3DView

    // === MOUSE KONTROL PARAMETRELERİ ===
    property real minZoomDistance: 5.0    // Minimum zoom mesafesi
    property real maxZoomDistance: 50.0   // Maksimum zoom mesafesi
    property real zoomSensitivity: 0.1    // Zoom hassasiyeti
    property real rotationSensitivity: 0.2 // Rotasyon hassasiyeti

    // Kamera kontrol değişkenleri
    property real cameraDistance: 25.0
    property real cameraYRotation: 0.0
    property bool mousePressed: false
    property point lastMousePosition: Qt.point(0, 0)

    // Açı değerleri
    property real rightPalAngle: 0
    property real bodyAngle: 0


    // === MOUSE KONTROL ALANI ===
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onPressed: {
            mousePressed = true
            lastMousePosition = Qt.point(mouse.x, mouse.y)
        }

        onReleased: {mousePressed = false}

        onPositionChanged: {
            if (mousePressed) {
                var deltaX = mouse.x - lastMousePosition.x

                // Sadece yatay eksende dönüş (Y ekseni etrafında)
                cameraYRotation += deltaX * rotationSensitivity

                // Kamera pozisyonunu güncelle
                lastMousePosition = Qt.point(mouse.x, mouse.y)
            }
        }

        onWheel: {
            // Zoom in/out kontrolü
            var delta = wheel.angleDelta.y * zoomSensitivity
            cameraDistance -= delta

            // Zoom sınırlarını kontrol et
            cameraDistance = Math.max(minZoomDistance, Math.min(maxZoomDistance, cameraDistance))

            // Kamera pozisyonunu güncelle
        }
    }


    // === 3D MODELLERİ (PAL SİSTEMİ) ===

    // Hançer (Araç) Entity'si
    Entity {
        parent: sceneRoot
        components: [
            SceneLoader {
                source: "qrc:/resource/models/Hancer_Root.obj"
            }
        ]
    }

}
