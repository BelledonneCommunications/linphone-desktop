import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================

ScrollBar {
    background: Rectangle {
        color: '#F4F4F4'
    }
    contentItem: Rectangle {
        color: scrollBar.pressed ? '#5E5E5F' : '#C5C5C5'
        implicitHeight: 100
        implicitWidth: 8
        radius: 10
    }
    id: scrollBar
}
