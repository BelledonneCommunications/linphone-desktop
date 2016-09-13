import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================

Button {
    property alias backgroundColor: background.color

    background: Rectangle {
        color: button.down ? '#FE5E00' : '#8E8E8E'
        id: background
        implicitHeight: 22
        radius: 10
    }
    contentItem: Text {
        color:'#FFFFFF'
        font.pointSize: 8
        horizontalAlignment: Text.AlignHCenter
        id: text
        text: button.text
        verticalAlignment: Text.AlignVCenter
    }
    id: button
}
