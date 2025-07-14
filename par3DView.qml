import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Extras 2.15

/*
    === KULLANIM ÖRNEĞİ ===

    Enhanced3DView {
        id: myView
        width: 800
        height: 600

        Component.onCompleted: {
            // Başlangıç değerleri
            setSlopeValue(15, -20)
            setColor(leftPalMaterial, "blue")
            setColor(rightPalMaterial, "green")
            setAngle(leftPalTransform, 25)
        }
    }
*/

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

    // === DIŞARI AÇILAN ÖZELLİKLER ===
    property var rightPalTransform: null
    property var bodyTransform: null

    property var rightPalMaterial: null
    property var bodyMaterial: null

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

        onReleased: {
            mousePressed = false
        }

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

    // === PAL HAREKETLERİ FONKSİYONLARI ===
    function setAngle(transform, angle) {
        if (transform && transform.rotationX !== undefined) {
            transform.rotationX += angle
            updateAngles()
            console.log("Açı verildi:", angle)
        }
    }

    // Açıları güncelleme fonksiyonu
    function updateAngles() {
        if ( rightPalTransform && bodyTransform) {
            rightPalAngle = rightPalTransform.rotationX
            bodyAngle = bodyTransform.rotationZ

            // Açı sınırlarını kontrol et
            rightPalAngle = Math.max(-90, Math.min(90, rightPalAngle))
            bodyAngle = Math.max(-90, Math.min(90, bodyAngle))
        }
    }

    // === IŞIK SİSTEMİ ===
    // Ana Directional Light (Güneş ışığı benzeri)
    Entity {
        id: mainLight
        parent: sceneRoot

        components: [
            DirectionalLight {
                id: mainDirectionalLight
                color: Qt.rgba(1.0, 1.0, 1.0, 1.0)  // Beyaz ışık
                intensity: 0.5  // Yoğunluk artırıldı
                worldDirection: Qt.vector3d(-1, -1, -1)  // Işık yönü
            },
            Transform {
                rotation: fromAxisAndAngle(Qt.vector3d(1, 0, 0), -45)
            }
        ]
    }

    // === 3D MODELLERİ (PAL SİSTEMİ) ===

    // Hançer (Araç) Entity'si
    Entity {
        parent: sceneRoot
        components: [
            Mesh {
                source: "qrc:/resource/acrob_govde.obj"
            },
            Transform {
                id: bodyTransformInternal
                translation: Qt.vector3d(0.0, 0.0, 0.0)
            },
            PhongMaterial {
                id: bodyMaterialInternal
                // Gövde rengi başlangıç ayarı (MTL DEN GELİR İSE EKLENMEYECEK.)
                ambient: Qt.rgba(0.17, 0.20, 0.13, 1)
            }
        ]
    }



    // Arka Pal Entity'si
    Entity {
        parent: sceneRoot
        components: [
            SceneLoader {
                source: "qrc:/resource/acrob_pal.obj"
            },
            Transform {
                id: rightPalTransformInternal
                translation: Qt.vector3d(0.0, 0.0, 0.0)
            },
            PhongMaterial {
                id: rightPalMaterialInternal
                diffuse: Qt.rgba(1, 0, 0, 1)
            }
        ]
    }

    // Component tamamlandığında referansları ata
    Component.onCompleted: {
        // Pal sistem referansları
        bodyTransform = bodyTransformInternal
        rightPalTransform = rightPalTransformInternal

        bodyMaterial = bodyMaterialInternal
        rightPalMaterial = rightPalMaterialInternal

        // Açıları güncelle
        updateAngles()
    }
}
