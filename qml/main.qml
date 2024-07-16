import QtQuick
import QtQuick.Window


Window {
    id: window
    width: 1400
    height: 900
    visible: true
    title: qsTr("Hello, World!")

    

    App {
        id: app
        anchors.fill: parent
    }
}