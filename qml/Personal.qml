import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    id: pers

    QtObject {
        id: internal

        property int idx: 0

        function add(){
            internal.idx = 0

            f_name.clear();
            f_pos.clear();
            f_start.clear();
            f_end.clear();

            form.visible = true;
        }

        function close() {
            form.visible = false
        }

        function save() {
            
            var card = {
                "id":internal.idx,
                "name":f_name.text,
                "pos":f_pos.text,
                "start":f_start.text,
                "end":f_end.text,
            }

            var res = modelPersonal.saveCard(card)
            if (res) {
                if (idx == 0){
                    add()
                } else {
                    close()
                }
            }
        }

        function edit(idx) {
            var card = modelPersonal.getCard(idx)

            internal.idx = card["id"]
            f_name.text = card["name"]
            f_pos.text = card["pos"]
            f_start.text = card["start"]
            f_end.text = card["end"]

            form.visible = true
        }

        function del() {
            var res = modelPersonal.delCard(internal.idx)
            if (res) {
                modelShedule.load()
                close()
            }
        }

        function xls(fileURL) {
            var r = modelShedule.makeXLS(fileURL)
            print(r)
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
                Layout.fillHeight: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 80
                highlighted: true

                Material.accent: Material.Orange
                Material.roundedScale: Material.SmallScale

                text: "Додати"
                onClicked: internal.add()

            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                Layout.fillHeight: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 80
                highlighted: true

                Material.accent: Material.Green
                Material.roundedScale: Material.SmallScale

                text: "XLSX"
                onClicked: fileDialog.open()

            }
        }

        Pane {
            id: form
            visible: false

            Material.elevation: 8

            Layout.minimumHeight: 180
            Layout.maximumHeight: 180
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                RowLayout {
                    Layout.minimumHeight: 45
                    Layout.maximumHeight: 45
                    Layout.fillWidth: true

                    spacing: 5
                    TextField {
                        id: f_name
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        placeholderText: "П.І.Б."
                        selectByMouse: true
                        clip: true
                        font.pointSize: 11

                    }
                    TextField {
                        id: f_pos
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        placeholderText: "Посада"
                        selectByMouse: true
                        clip: true
                        font.pointSize: 11                        
                    }
                }
                RowLayout {
                    Layout.minimumHeight: 45
                    Layout.maximumHeight: 45
                    Layout.fillWidth: true
                    spacing: 5

                    TextField {
                        id: f_start
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 120

                        placeholderText: "Дата початку роботи"
                        selectByMouse: true
                        clip: true
                        validator: RegularExpressionValidator { regularExpression: /\b(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.(\d{4})\b/ }

                        
                    }
                    TextField {
                        id: f_end
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 120

                        placeholderText: "Дата звільнення"
                        selectByMouse: true
                        clip: true
                        validator: RegularExpressionValidator { regularExpression: /\b(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.(\d{4})\b/ }
                        
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
            id: tablePersonal
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5

            model: modelPersonal
            clip: true
            delegate: Rectangle {

                required property int index
                required property string name
                required property string pos
                required property string start
                required property string end

                height: 35
                width: tablePersonal.width
                radius: 5
                
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    spacing: 5

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: name
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 250
                        Layout.maximumWidth: 250

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: pos
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 80
                        Layout.maximumWidth: 80

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: start
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.minimumWidth: 80
                        Layout.maximumWidth: 80

                        font.pointSize: 11
                        verticalAlignment: Qt.AlignVCenter
                        text: end
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: parent.color = containsMouse ? "#f4cd7a" : "transparent"
                    onDoubleClicked: internal.edit(index)
                    onClicked: internal.close()
                }
            }            
        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["EXcel files (*.xlsx)"]
        onAccepted: internal.xls(selectedFile)
    }
    
}