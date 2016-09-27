import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone.Styles 1.0

// ===================================================================

ScrollBar {
    background: ScrollBarStyle.background
    contentItem: Rectangle {
        color: pressed
            ? ScrollBarStyle.pressedColor
            : ScrollBarStyle.color
        implicitHeight: ScrollBarStyle.contentItem.implicitHeight
        implicitWidth: ScrollBarStyle.contentItem.implicitWidth
        radius: ScrollBarStyle.contentItem.radius
    }
}
