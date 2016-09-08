import QtQuick 2.7
import QtQuick.Controls 2.0

Button {
    background: Rectangle {
        color: button.down ? '#FE5E00' : '#434343'
        implicitWidth: 120
        implicitHeight: 30
        radius: 4
    }
    contentItem: Text {
        color: '#FFFFFF'
        text: button.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    id: button
}
