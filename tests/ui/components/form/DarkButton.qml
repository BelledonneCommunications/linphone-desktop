import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================

Button {
    property string backgroundColor: '#434343'
    property string textColor: '#FFFFFF'

    background: Rectangle {
        color: button.down ? '#FE5E00' : backgroundColor
        implicitHeight: 30
        implicitWidth: 160
        radius: 4
    }
    contentItem: Text {
        color: button.down ? '#FFFFFF' : textColor
        font.pointSize: 8
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        id: text
        text: button.text
        verticalAlignment: Text.AlignVCenter
    }
    id: button
}
