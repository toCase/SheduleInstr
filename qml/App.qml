import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: app

    QtObject {
        id: internal

        function showMessage(messa){
            messageBox.visible = true
            message.text = messa
            messageTimer.start()
        }
    }

    Connections {
        target: modelPersonal
        function onError(error){
            internal.showMessage(error)
        }
    }

    Connections {
        target: modelShedule
        function onError(error){
            internal.showMessage(error)
        }
    }


    RowLayout {
        anchors.fill: app
        anchors.margins: 10
        spacing: 10

        Personal {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Generate {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Timer {
        id: messageTimer
        repeat: false
        running: false
        interval: 3000
        onTriggered: messageBox.visible = false
    }

    Rectangle {
        id: messageBox
        visible: false
        x: 50
        y: app.height - 50
        width: app.width * .8
        height: 40
        radius: 5

        color: "#E91E63"

        Text {
            id: message
            anchors.fill: parent
            anchors.rightMargin: 15
            anchors.leftMargin: 15

            font.pointSize: 11
            verticalAlignment: Qt.AlignVCenter
            color: "#FFFFFF"
        }
    }

    
}