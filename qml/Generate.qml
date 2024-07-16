import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: gen

    QtObject {
        id: internal

        property int idx:0

        function gen() {
            var param = {
                "to": sett_to.text,
                "interval": sett_days.text
            };
            var r = modelShedule.generateShedule(param);
        }

        function add() {
            internal.idx = 0;
            f_testdate.clear()
            f_testdate.focus = true
            f_personal.currentIndex = 0
            f_testtype.currentIndex = 0
            f_reason.clear()

            form.visible = true

        }

        function edit(i) {
            var card = modelShedule.getCard(i)
            internal.idx = card["id"]
            f_testdate.text = card["testdate"]
            f_personal.currentIndex = f_personal.find(card["personalName"])
            f_testtype.currentIndex = f_testtype.find(card["testtype"])
            f_reason.text = card["reason"]

            form.visible = true

        }

        function del() {
            var res = modelShedule.delCard(internal.idx)
            if (res) {
                close()
            }

        }

        function save() {
            var card = {
                "id": internal.idx,
                "personal": f_personal.currentValue,
                "testdate": f_testdate.text,
                "testtype": f_testtype.currentText,
                "reason": f_reason.text,
            }

            var res = modelShedule.saveCard(card)
            if (res) {
                if (internal.idx == 0){
                    add()
                } else {
                    close()
                }
            }
        }

        function close() {
            form.visible = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.minimumHeight: 42
            Layout.maximumHeight: 42
            Layout.fillWidth: true

            spacing: 5

            Button {
                id: but_gen
                Layout.fillHeight: true
                Layout.minimumWidth: 120
                Layout.maximumWidth: 120
                Layout.alignment: Qt.AlignVCenter

                highlighted: true

                Material.accent: Material.Orange
                Material.roundedScale: Material.SmallScale

                text: "Створити"
                onClicked: internal.gen()
            }
            Text {
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.minimumWidth: implicitWidth
                Layout.maximumWidth: implicitWidth
                 Layout.alignment: Qt.AlignVCenter

                // Layout.verticalAlignment: Qt.AlignVCenter
                text: "До: "
                verticalAlignment: Qt.AlignVCenter
                font.pointSize: 11
            }

            TextField {
                id: sett_to
                Layout.fillHeight: true
                Layout.minimumWidth: 120
                Layout.maximumWidth: 120
                Layout.alignment: Qt.AlignVCenter

                selectByMouse: true
                clip: true
                validator: RegularExpressionValidator {
                    regularExpression: /\b(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.(\d{4})\b/
                }
                text: helpers.currentDate
                font.pointSize: 11
                horizontalAlignment: Qt.AlignHCenter
            }

            Text {
                Layout.fillHeight: true
                Layout.minimumWidth: implicitWidth
                Layout.maximumWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter
                text: "Проміжок в днях: "
                verticalAlignment: Qt.AlignVCenter
                font.pointSize: 11
            }

            TextField {
                id: sett_days
                Layout.fillHeight: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 80
                Layout.alignment: Qt.AlignVCenter

                selectByMouse: true
                clip: true
                validator: IntValidator {
                    bottom: 0
                    top: 999
                }
                text: "180"
                font.pointSize: 11
                verticalAlignment: Qt.AlignHCenter
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                Layout.fillHeight: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 80
                Layout.alignment: Qt.AlignVCenter

                highlighted: true

                Material.accent: Material.Orange
                Material.roundedScale: Material.SmallScale

                text: "Додати"
                onClicked: internal.add()
            }
        }

        Pane {
            id: form
            visible: false

            Material.elevation: 8

            Layout.minimumHeight: 220
            Layout.maximumHeight: 220
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                RowLayout {
                    Layout.minimumHeight: 42
                    Layout.maximumHeight: 42
                    Layout.fillWidth: true

                    spacing: 5
                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: implicitWidth
                        Layout.maximumWidth: implicitWidth

                        text: "Дата:"
                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: f_testdate
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 120

                        selectByMouse: true
                        clip: true
                        validator: RegularExpressionValidator { regularExpression: /\b(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.(\d{4})\b/ }                        

                        
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: implicitWidth
                        Layout.maximumWidth: implicitWidth

                        text: "Особа:"
                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                    }
                    ComboBox {
                        id: f_personal
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        model: modelPersonal
                        textRole: "name"
                        valueRole: "pk"

                    }
                }
                RowLayout {
                    Layout.minimumHeight: 42
                    Layout.maximumHeight: 42
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: implicitWidth
                        Layout.maximumWidth: implicitWidth

                        text: "Вид:"
                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                    }
                    ComboBox {
                        id: f_testtype
                        Layout.fillHeight: true
                        Layout.minimumWidth: 200
                        Layout.maximumWidth: 200

                        model: helpers.testTypes
                        // font.pointSize: 11
                    }
                    Item {
                        Layout.fillWidth: true
                    }                    
                }
                RowLayout {
                    Layout.minimumHeight: 42
                    Layout.maximumHeight: 42
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: implicitWidth
                        Layout.maximumWidth: implicitWidth

                        text: "Причина:"
                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: f_reason
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        selectByMouse: true
                        clip: true
                    }                   
                }
                RowLayout {
                    Layout.minimumHeight: 42
                    Layout.maximumHeight: 42
                    Layout.fillWidth: true

                    spacing: 5

                    Button {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 100
                        highlighted: true


                        Material.accent: Material.Pink
                        Material.roundedScale: Material.SmallScale

                        text: "Видалити"
                        onClicked: internal.del()

                    }
                    Item {
                        Layout.fillWidth: true
                        
                    }
                    Button {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 100
                        highlighted: true

                        Material.accent: Material.Teal
                        Material.roundedScale: Material.SmallScale

                        text: "Зберегти"
                        onClicked: internal.save()

                    }
                    Button {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 60
                        Layout.maximumWidth: 60
                        highlighted: true

                        Material.accent: Material.Teal
                        Material.roundedScale: Material.SmallScale

                        text: "Х"
                        onClicked: internal.close()

                    }
                }
            }
        }

        ListView {
            id: tableShedule
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5

            model: modelShedule
            clip: true
            delegate: Rectangle {

                required property int index
                required property string personal
                required property string testdate
                required property string testtype
                required property color clr

                height: 35
                width: tableShedule.width
                radius: 5

                color: clr


                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    spacing: 15

                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 80
                        Layout.maximumWidth: 80

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: testdate
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: personal
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 150
                        Layout.maximumWidth: 150

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: testtype
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: parent.color = containsMouse ? "#7FC8E8" : clr
                    onDoubleClicked: internal.edit(index)
                    // onClicked: internal.close()
                }
            }
            ScrollBar.vertical: ScrollBar {}
        }
    }
}
