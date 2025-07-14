import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Scene3D 2.15
import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Input 2.15
import Qt3D.Extras 2.15

Item {
    id: base3DView
    visible: true
    width: 1920
    height: 1080

    // === RESPONSIVE SCALING PROPERTİES ===
    property real baseWidth: 1920
    property real baseHeight: 1080
    property real screenWidth: Screen.width || parent.width
    property real screenHeight: Screen.height || parent.height
    property real scaleFactor: Math.min(screenWidth / baseWidth, screenHeight / baseHeight)
    property real responsiveScale: Math.max(0.6, Math.min(2.0, scaleFactor))

    // === DIŞARI AÇILAN ÖZELLİKLER ===

    // Cetvel değerleri - dışarıdan erişilebilir
    property real leftCetvelValue: 0  // Sol cetvel değeri
    property real bottomCetvelValue: 0 // Alt cetvel değeri

    // Design parametreleri - responsive hale getirildi
    property int marginValue: 25 * responsiveScale
    property int rulerWidth: 12 * responsiveScale
    property int majorTickSize: 10 * responsiveScale
    property int midTickSize: 6 * responsiveScale
    property int minorTickSize: 3 * responsiveScale
    property int majorTickSpacing: 30
    property int midTickSpacing: 15
    property int minorTickSpacing: 3

    // Font ve text boyutları
    property real baseFontSize: 8 * responsiveScale
    property real labelFontSize: 12 * responsiveScale
    property real warningFontSize: 13 * responsiveScale

    // 3D Sahne referansı - child component'lerin erişebilmesi için
    property alias scene3d: scene3d
    property alias sceneRoot: sceneRoot
    property alias camera: camera

    // === WARNING POP-UP İÇİN TIMER ===
    Timer {
        id: warningTimer
        interval: 1500
        repeat: false
        onTriggered: {
            fadeOutAnimation.start()
        }
    }

    // === GENEL AMAÇLI FONKSİYONLAR ===

    // Warning Pop-up gösterme fonksiyonu
    function setWarning(message) {
        warningText.text = message
        warningPopup.visible = true
        warningTimer.restart()
        logger.info("Warning - ",+ message)
    }

    // Cetvel değerlerini ayarlama fonksiyonu
    function setSlopeValue(verticalValue, horizontalValue) {
        horizontalValue = Math.max(-90, Math.min(90, horizontalValue)) ;
        verticalValue = Math.max(-90, Math.min(90, verticalValue)) ;

        leftCetvelValue = verticalValue
        bottomCetvelValue = horizontalValue

        if (verticalValue > 60 || verticalValue < -60  || horizontalValue > 60 || horizontalValue <-60)
            setWarning("Devrilme Uyarısı")

        console.log("Cetvel değerleri güncellendi - Sol:", verticalValue, "Alt:", horizontalValue)
    }

    // Renk ayarlama fonksiyonu
    function setColor(material, colorName) {
        if (material) {
            material.diffuse = Qt.color(colorName)
            console.log("Renk atandı:", colorName)
        }
    }

    // Arka plan
    Rectangle {
        anchors.fill: parent
        color: "#414143" // Koyu arka plan
    }

    // === 3D SAHNE ===
    Scene3D {
        id: scene3d
        anchors.fill: parent
        aspects: ["input", "logic"]
        cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

        Entity {
            id: sceneRoot

            Camera {
                id: camera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 45
                aspectRatio: 16 / 9
                nearPlane: 0.1
                farPlane: 800.0
                position: Qt.vector3d(2.0, 10.0, 25.0)
                upVector: Qt.vector3d(0.0, 1.0, 0.0)
                viewCenter: Qt.vector3d(0.0, 0.0, 0.0)
            }

            OrbitCameraController {
                id: orbitController
                camera: camera
                zoomInLimit: 2.0
                linearSpeed: 50.0
                lookSpeed: 360.0
            }

            components: [
                RenderSettings {
                    activeFrameGraph: ForwardRenderer {
                        clearColor: Qt.rgba(0.4, 0.4, 0.4, 1)
                        camera: camera
                    }
                },
                InputSettings {}
            ]
        }
    }

    // === WARNING POP-UP ===
    Rectangle {
        id: warningPopup
        visible: false
        width: warningContent.width + (60 * responsiveScale)
        height: warningContent.height + (40 * responsiveScale)
        anchors.centerIn: parent
        z: 100

        color: "#4A4A4A"
        radius: 8 * responsiveScale
        border.width: 2 * responsiveScale
        border.color: "#5A5A5A"

        // Gölge efekti
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4 * responsiveScale
            z: -1
            radius: parent.radius + (2 * responsiveScale)
            color: "#30000000"
        }

        // Üst başlık kısmı
        Rectangle {
            id: headerRect
            width: parent.width
            height: 35 * responsiveScale
            anchors.top: parent.top
            color: "#5A5A5A"
            radius: parent.radius

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.radius
                color: parent.color
            }

            // Başlık metni
            Text {
                text: "- UYARI -"
                font.pixelSize: warningFontSize
                font.bold: true
                color: "#ffa800"
                anchors.centerIn: parent
            }
        }

        Column {
            id: warningContent
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 8 * responsiveScale
            spacing: 8 * responsiveScale

            // Warning Text
            Text {
                id: warningText
                text: "Warning Message"
                font.pixelSize: warningFontSize
                color: "#D9D9D9"
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }
        }

        PropertyAnimation {
            id: fadeInAnimation
            target: warningPopup
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
            easing.type: Easing.OutQuad
        }

        PropertyAnimation {
            id: fadeOutAnimation
            target: warningPopup
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 300
            easing.type: Easing.InQuad
            onFinished: warningPopup.visible = false
        }

        // Scale animasyonu
        PropertyAnimation {
            id: scaleInAnimation
            target: warningPopup
            property: "scale"
            from: 0.8
            to: 1.0
            duration: 200
            easing.type: Easing.OutBack
        }

        onVisibleChanged: {
            if (visible) {
                opacity = 0
                scale = 0.8
                fadeInAnimation.start()
                scaleInAnimation.start()
            }
        }
    }

    // === SOL CETVEL ===
    Rectangle {
        id: leftRuler
        width: rulerWidth
        opacity: 0.6
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            topMargin: marginValue
            bottomMargin: marginValue
        }
        color: "#555555"
        border.color: "#333333"
        border.width: 1 * responsiveScale
        z: 10

        // Cetvel çizgileri
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "#FFFFFF"

                // Ana çizgiler (30 derece aralıklarla)
                for (var i = -90; i <= 90; i += majorTickSpacing) {
                    var y = parent.height / 2 - (i * parent.height / 180)
                    ctx.fillRect(parent.width - majorTickSize, y, majorTickSize, 1)

                    // Her 30 derecede bir sayıları göster
                    if (i % majorTickSpacing === 0) {
                        ctx.font = baseFontSize + "px sans-serif"
                        ctx.textAlign = "right"
                        ctx.fillText(i + "°", parent.width - majorTickSize - (3 * responsiveScale), y + (3 * responsiveScale))
                    }
                }

                // Orta çizgiler (15 derece aralıklarla)
                for (var j = -90; j <= 90; j += midTickSpacing) {
                    if (j % majorTickSpacing !== 0) {
                        var y = parent.height / 2 - (j * parent.height / 180)
                        ctx.fillRect(parent.width - midTickSize, y, midTickSize, 1)
                    }
                }

                // En küçük çizgiler (3 derece aralıklarla)
                for (var k = -90; k <= 90; k += minorTickSpacing) {
                    if (k % midTickSpacing !== 0) {
                        var y = parent.height / 2 - (k * parent.height / 180)
                        ctx.fillRect(parent.width - minorTickSize, y, minorTickSize, 1)
                    }
                }
            }
        }

        // Gösterge işaretçisi
        Rectangle {
            id: leftSlopeIndicator
            width: 8 * responsiveScale
            height: 2 * responsiveScale
            color: "#ffa800"
            x: parent.width - width + (2 * responsiveScale)
            y: parent.height / 2 - (leftCetvelValue * parent.height / 180) - height / 2
        }

        // Gösterge üçgeni
        Canvas {
            width: 6 * responsiveScale
            height: 6 * responsiveScale
            x: leftSlopeIndicator.x + leftSlopeIndicator.width
            y: leftSlopeIndicator.y - (2 * responsiveScale)
            contextType: "2d"

            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "#FF9500"
                ctx.beginPath()
                ctx.moveTo(0, 3 * responsiveScale)
                ctx.lineTo(6 * responsiveScale, 0)
                ctx.lineTo(6 * responsiveScale, 6 * responsiveScale)
                ctx.closePath()
                ctx.fill()
            }
        }

        // Gösterge metni
        Rectangle {
            color: "#333333"
            border.color: "#AAAAAA"
            border.width: 1 * responsiveScale
            radius: 2 * responsiveScale
            width: leftValueText.width + (8 * responsiveScale)
            height: leftValueText.height + (4 * responsiveScale)
            anchors {
                left: leftRuler.right
                verticalCenter: leftSlopeIndicator.verticalCenter
                leftMargin: 5 * responsiveScale
            }

            Text {
                id: leftValueText
                text: Math.abs(leftCetvelValue).toFixed(1) + "°"
                color: "#FFFFFF"
                font.pixelSize: labelFontSize
                font.bold: true
                anchors.centerIn: parent
            }
        }
    }

    // === ALT CETVEL ===
    Rectangle {
        id: bottomRuler
        height: rulerWidth
        opacity: 0.6
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: marginValue * 2
            rightMargin: marginValue * 2
        }
        color: "#555555"
        border.color: "#333333"
        border.width: 1 * responsiveScale
        z: 10

        // Cetvel çizgileri
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "#FFFFFF"

                // Ana çizgiler (30 derece aralıklarla)
                for (var i = -90; i <= 90; i += majorTickSpacing) {
                    var x = parent.width / 2 + (i * parent.width / 180)
                    ctx.fillRect(x, 0, 1, majorTickSize)

                    // Her 30 derecede bir sayıları göster
                    if (i % majorTickSpacing === 0) {
                        ctx.font = baseFontSize + "px sans-serif"
                        ctx.textAlign = "center"
                        ctx.fillText(i + "°", x, majorTickSize + (9 * responsiveScale))
                    }
                }

                // Orta çizgiler (15 derece aralıklarla)
                for (var j = -90; j <= 90; j += midTickSpacing) {
                    if (j % majorTickSpacing !== 0) {
                        var x = parent.width / 2 + (j * parent.width / 180)
                        ctx.fillRect(x, 0, 1, midTickSize)
                    }
                }

                // En küçük çizgiler (3 derece aralıklarla)
                for (var k = -90; k <= 90; k += minorTickSpacing) {
                    if (k % midTickSpacing !== 0) {
                        var x = parent.width / 2 + (k * parent.width / 180)
                        ctx.fillRect(x, 0, 1, minorTickSize)
                    }
                }
            }
        }

        // Gösterge işaretçisi
        Rectangle {
            id: bottomSlopeIndicator
            width: 2 * responsiveScale
            height: 8 * responsiveScale
            color: "#ffa800"
            x: parent.width / 2 + (bottomCetvelValue * parent.width / 180) - width / 2
            y: 0
        }

        // Gösterge üçgeni
        Canvas {
            width: 6 * responsiveScale
            height: 6 * responsiveScale
            x: bottomSlopeIndicator.x - (2 * responsiveScale)
            y: bottomSlopeIndicator.y - (6 * responsiveScale)
            contextType: "2d"

            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = "#FF9500"
                ctx.beginPath()
                ctx.moveTo(0, 6 * responsiveScale)
                ctx.lineTo(6 * responsiveScale, 6 * responsiveScale)
                ctx.lineTo(3 * responsiveScale, 0)
                ctx.closePath()
                ctx.fill()
            }
        }

        // Gösterge metni
        Rectangle {
            color: "#333333"
            border.color: "#AAAAAA"
            border.width: 1 * responsiveScale
            radius: 2 * responsiveScale
            width: bottomValueText.width + (8 * responsiveScale)
            height: bottomValueText.height + (4 * responsiveScale)
            anchors {
                bottom: bottomRuler.top
                horizontalCenter: bottomSlopeIndicator.horizontalCenter
                bottomMargin: 5 * responsiveScale
            }

            Text {
                id: bottomValueText
                text: Math.abs(bottomCetvelValue).toFixed(1) + "°"
                color: "#FFFFFF"
                font.pixelSize: labelFontSize
                font.bold: true
                anchors.centerIn: parent
            }
        }
    }
}
