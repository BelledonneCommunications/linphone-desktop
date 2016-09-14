import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================
// Checkbox with clickable text.
// ===================================================================

CheckBox {
    contentItem: Text {
        color: checkBox.down ? '#FE5E00' : '#8E8E8E'
        font: checkBox.font
        horizontalAlignment: Text.AlignHCenter
        leftPadding: checkBox.indicator.width + checkBox.spacing
        text: checkBox.text
        verticalAlignment: Text.AlignVCenter
    }
    id: checkBox
    indicator: Rectangle {
        border.color: checkBox.down ? '#FE5E00' : '#8E8E8E'
        implicitHeight: 18
        implicitWidth: 18
        radius: 3
        x: checkBox.leftPadding
        y: parent.height / 2 - height / 2

        Rectangle {
            color: checkBox.down ? '#FE5E00' : '#8E8E8E'
            height: 10
            radius: 2
            visible: checkBox.checked
            width: 10
            x: 4
            y: 4
        }
    }
}
