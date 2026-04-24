import QtQuick
import QtQuick.Controls

/*
  Kullanım örneği:
  ─────────────────────────────────────────────────────────────────
  MenuView {
      id: root
      title: "Araç Sistemi"

      VehicleControlView {
          anchors.centerIn: parent

          onLightToggled: function(lightId, state) {
              vehicleController.setLight(lightId, state)
          }
          onMastMoved: function(direction) {
              vehicleController.mastMove(direction)   // "UP" | "DOWN"
          }
      }
  }
  ─────────────────────────────────────────────────────────────────
*/

Item {
    id: root

    // ── Responsive Scale — mevcut projeyle aynı formül ────────────
    property real scaleFactor:     Math.min(Screen.width / 1920, Screen.height / 1080)
    property real responsiveScale: Math.max(0.6, Math.min(2.0, scaleFactor))

    // ── Sinyaller ─────────────────────────────────────────────────
    signal lightToggled(string lightId, bool state)
    signal mastMoved(string direction)   // "UP" veya "DOWN"

    // ── Boyut: switch sayısına göre dinamik ───────────────────────
    width:  320 * responsiveScale
    height: contentColumn.implicitHeight

    // ── Mast zamanlayıcıları (basılı tut → tekrarlı sinyal) ───────
    Timer {
        id: mastUpTimer
        interval: 150
        repeat: true
        triggeredOnStart: true
        onTriggered: root.mastMoved("UP")
    }
    Timer {
        id: mastDownTimer
        interval: 150
        repeat: true
        triggeredOnStart: true
        onTriggered: root.mastMoved("DOWN")
    }

    // ══════════════════════════════════════════════════════════════
    // VERİ MODELİ
    // ══════════════════════════════════════════════════════════════
    property var switchItems: [
        { id: "frontLight",   text: qsTr("Ön Lamba"),           icon: "qrc:/resource/icons/toolbar_lights_icon.png"   },
        { id: "rearLight",    text: qsTr("Arka Lamba"),         icon: "qrc:/resource/icons/toolbar_lights_icon.png"    },
        { id: "ventilation",  text: qsTr("Havalandırma"),       icon: "qrc:/resource/icons/toolbar_cooler_fan_icon.png"   },
        { id: "ambientLight", text: qsTr("Çevre Aydınlatma"),   icon: "qrc:/resource/icons/toolbar_peripheral_lamp_icon.png" }
    ]

    property var mastItems: [
        { dir: "UP",   label: qsTr("Mast Yukarı"), arrow: "▲" },
        { dir: "DOWN", label: qsTr("Mast Aşağı"),  arrow: "▼" }
    ]

    // ══════════════════════════════════════════════════════════════
    // GÖLGE
    // ══════════════════════════════════════════════════════════════
    Rectangle {
        x: 3 * responsiveScale
        y: 3 * responsiveScale
        width:  parent.width
        height: parent.height
        color:  "#40000000"
        z: -1
    }

    // ══════════════════════════════════════════════════════════════
    // ANA KART
    // ══════════════════════════════════════════════════════════════
    Rectangle {
        id: card
        anchors.fill: parent
        color:        themeManager.backgroundColor
        border.color: "#555555"
        border.width: 1 * responsiveScale

        Column {
            id: contentColumn
            width: parent.width

            // ── HEADER ────────────────────────────────────────────
            Rectangle {
                id: headerRect
                width:  parent.width
                height: 60 * responsiveScale
                color:  "#404040"
                radius: 8 * responsiveScale

                // Alt köşeleri düzelt
                Rectangle {
                    width:  parent.width
                    height: 30 * responsiveScale
                    color:  parent.color
                    anchors.bottom: parent.bottom
                }

                Text {
                    text:  qsTr("Araç Sistemi")
                    color: themeManager.orangeColor
                    font.pixelSize: 16 * responsiveScale
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 12 * responsiveScale
                }

                // Dekoratif çizgi — DropDownMenu ile birebir aynı
                Row {
                    anchors.bottom:       parent.bottom
                    anchors.bottomMargin: 8 * responsiveScale
                    anchors.left:         parent.left
                    anchors.leftMargin:   15 * responsiveScale
                    spacing: 1 * responsiveScale

                    Rectangle {
                        width: 10 * responsiveScale; height: 5 * responsiveScale
                        color: themeManager.orangeColor; radius: 2 * responsiveScale
                        transform: Rotation { angle: -60; origin.x: 6 * responsiveScale; origin.y: 2 * responsiveScale }
                    }
                    Rectangle {
                        width: 10 * responsiveScale; height: 5 * responsiveScale
                        color: themeManager.whiteColor; radius: 2 * responsiveScale
                        transform: Rotation { angle: -60; origin.x: 6 * responsiveScale; origin.y: 2 * responsiveScale }
                    }
                    Rectangle {
                        width: 10 * responsiveScale; height: 5 * responsiveScale
                        color: themeManager.redColor; radius: 2 * responsiveScale
                        transform: Rotation { angle: -60; origin.x: 6 * responsiveScale; origin.y: 2 * responsiveScale }
                    }
                    Rectangle {
                        width:  card.width - 65 * responsiveScale
                        height: 7 * responsiveScale
                        color:  themeManager.dividerColor
                        radius: 2 * responsiveScale
                        anchors.verticalCenter: parent.verticalCenter
                        y: -2 * responsiveScale
                    }
                }
            }

            // ── SWITCH SATIRLARI ──────────────────────────────────
            Repeater {
                id: switchRepeater
                model: root.switchItems

                delegate: Item {
                    id: switchRow
                    width:  card.width
                    height: 50 * responsiveScale

                    property bool isOn: false

                    Rectangle {
                        anchors.fill: parent
                        color: rowMouse.containsMouse
                               ? "#4A4A4A"
                               : themeManager.backgroundColor
                        radius: 0

                        Behavior on color { ColorAnimation { duration: 200 } }

                        // Sol turuncu vurgu çizgisi (açıkken)
                        Rectangle {
                            width:   3 * responsiveScale
                            height:  parent.height * 0.55
                            radius:  2 * responsiveScale
                            color:   themeManager.orangeColor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            visible: switchRow.isOn
                            opacity: 0.9
                        }

                        Row {
                            anchors.left:           parent.left
                            anchors.leftMargin:     15 * responsiveScale
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:                15 * responsiveScale

                            // İkon dairesi
                            Rectangle {
                                width:  32 * responsiveScale
                                height: 32 * responsiveScale
                                radius: 16 * responsiveScale
                                color:  switchRow.isOn ? "#5a3e00" : "#555555"
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 200 } }

                                Image {
                                    width:    20 * responsiveScale
                                    height:   20 * responsiveScale
                                    source:   modelData.icon || ""
                                    anchors.centerIn: parent
                                    visible:  modelData.icon !== undefined && modelData.icon !== ""
                                    fillMode: Image.PreserveAspectFit
                                }
                                // İkon yoksa fallback daire
                                Rectangle {
                                    width:  16 * responsiveScale
                                    height: 16 * responsiveScale
                                    radius: 8 * responsiveScale
                                    color:  switchRow.isOn ? themeManager.orangeColor : "#777777"
                                    anchors.centerIn: parent
                                    visible: !modelData.icon || modelData.icon === ""
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }

                            // Etiket
                            Text {
                                text:  qsTr(modelData.text)
                                color: switchRow.isOn ? themeManager.orangeColor : themeManager.whiteColor
                                font.pixelSize: 15 * responsiveScale
                                font.bold:      switchRow.isOn
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }

                        // Durum etiketi
                        Text {
                            text:  switchRow.isOn ? qsTr("AÇ") : qsTr("KAPALI")
                            color: switchRow.isOn ? themeManager.orangeColor : "#777777"
                            font.pixelSize: 11 * responsiveScale
                            font.letterSpacing: 1
                            anchors.right:          toggleItem.left
                            anchors.rightMargin:    8 * responsiveScale
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        // Custom Toggle Switch
                        Item {
                            id: toggleItem
                            width:  44 * responsiveScale
                            height: 24 * responsiveScale
                            anchors.right:          parent.right
                            anchors.rightMargin:    15 * responsiveScale
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color:  switchRow.isOn ? themeManager.orangeColor : "#1E2D3D"
                                border.color: switchRow.isOn ? themeManager.orangeColor : "#555555"
                                border.width: 1 * responsiveScale
                                Behavior on color { ColorAnimation { duration: 220 } }
                            }
                            Rectangle {
                                width:  18 * responsiveScale
                                height: 18 * responsiveScale
                                radius: 9 * responsiveScale
                                color:  switchRow.isOn ? themeManager.backgroundColor : "#777777"
                                anchors.verticalCenter: parent.verticalCenter
                                x: switchRow.isOn
                                   ? parent.width - width - 3 * responsiveScale
                                   : 3 * responsiveScale
                                Behavior on x     { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                switchRow.isOn = !switchRow.isOn
                                root.lightToggled(modelData.id, switchRow.isOn)
                            }
                        }

                        // Ayraç çizgisi
                        Rectangle {
                            width:  parent.width - 30 * responsiveScale
                            height: 1 * responsiveScale
                            color:  "#555555"
                            anchors.bottom:           parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // ── MAST BÖLÜMÜ BAŞLIĞI ───────────────────────────────
            Rectangle {
                id: mastHeader
                width:  parent.width
                height: 36 * responsiveScale
                color:  "#333333"

                Text {
                    text: qsTr("Mast Sistemi")
                    color: themeManager.orangeColor
                    font.pixelSize: 13 * responsiveScale
                    font.bold: true
                    font.letterSpacing: 1.5
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * responsiveScale
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    height: 2 * responsiveScale
                    color:  themeManager.dividerColor
                    radius: 1 * responsiveScale
                    anchors.left:           parent.left
                    anchors.leftMargin:     145 * responsiveScale
                    anchors.right:          parent.right
                    anchors.rightMargin:    15 * responsiveScale
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ── MAST YUKARI / AŞAĞI SATIRLARI ────────────────────
            Repeater {
                model: root.mastItems

                delegate: Item {
                    id: mastRow
                    width:  card.width
                    height: 50 * responsiveScale

                    property bool isPressed: false

                    Rectangle {
                        anchors.fill: parent
                        color: mastRow.isPressed
                               ? "#5a3e00"
                               : mastMouse.containsMouse
                                 ? "#4A4A4A"
                                 : themeManager.backgroundColor

                        // Son eleman — alt köşe yuvarla
                        radius: index === root.mastItems.length - 1 ? 8 * responsiveScale : 0
                        Rectangle {
                            visible: index === root.mastItems.length - 1
                            width:  parent.width
                            height: parent.height / 2
                            color:  parent.color
                            anchors.top: parent.top
                        }

                        Behavior on color { ColorAnimation { duration: 100 } }

                        // Sol turuncu çizgi (basılıyken)
                        Rectangle {
                            width:   3 * responsiveScale
                            height:  parent.height * 0.55
                            radius:  2 * responsiveScale
                            color:   themeManager.orangeColor
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            visible: mastRow.isPressed
                        }

                        Row {
                            anchors.left:           parent.left
                            anchors.leftMargin:     15 * responsiveScale
                            anchors.verticalCenter: parent.verticalCenter
                            spacing:                15 * responsiveScale

                            // Ok dairesi
                            Rectangle {
                                width:  32 * responsiveScale
                                height: 32 * responsiveScale
                                radius: 16 * responsiveScale
                                color:  mastRow.isPressed ? themeManager.orangeColor : "#555555"
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    text:  modelData.arrow
                                    color: mastRow.isPressed
                                           ? themeManager.backgroundColor
                                           : themeManager.whiteColor
                                    font.pixelSize: 14 * responsiveScale
                                    font.bold: true
                                    anchors.centerIn: parent
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }

                            // Etiket
                            Text {
                                text:  modelData.label
                                color: mastRow.isPressed
                                       ? themeManager.orangeColor
                                       : themeManager.whiteColor
                                font.pixelSize: 15 * responsiveScale
                                font.bold:      mastRow.isPressed
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                        }

                        // Sağ: basılı tut güç göstergesi
                        Row {
                            anchors.right:          parent.right
                            anchors.rightMargin:    15 * responsiveScale
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3 * responsiveScale
                            opacity: mastRow.isPressed ? 1.0 : 0.25
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Repeater {
                                model: 3
                                Rectangle {
                                    width:  4 * responsiveScale
                                    height: (index + 1) * 5 * responsiveScale
                                    radius: 2 * responsiveScale
                                    color:  themeManager.orangeColor
                                    anchors.bottom: parent ? parent.bottom : undefined
                                }
                            }
                        }

                        MouseArea {
                            id: mastMouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onPressed: {
                                mastRow.isPressed = true
                                if (modelData.dir === "UP") mastUpTimer.start()
                                else                        mastDownTimer.start()
                            }
                            onReleased: {
                                mastRow.isPressed = false
                                mastUpTimer.stop()
                                mastDownTimer.stop()
                            }
                            onCanceled: {
                                mastRow.isPressed = false
                                mastUpTimer.stop()
                                mastDownTimer.stop()
                            }
                        }

                        // Ayraç — sadece ilk eleman
                        Rectangle {
                            width:  parent.width - 30 * responsiveScale
                            height: 1 * responsiveScale
                            color:  "#555555"
                            anchors.bottom:           parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: index === 0
                        }
                    }
                }
            }

        } // Column
    } // Rectangle card
} // Item root
