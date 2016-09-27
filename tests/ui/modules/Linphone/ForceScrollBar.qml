import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone.Styles 1.0

// ===================================================================

ScrollBar {
    background: ForceScrollBarStyle.background
    contentItem: Rectangle {
        color: pressed
            ? ForceScrollBarStyle.pressedColor
            : ForceScrollBarStyle.color
        implicitHeight: ForceScrollBarStyle.contentItem.implicitHeight
        implicitWidth: ForceScrollBarStyle.contentItem.implicitWidth
        radius: ForceScrollBarStyle.contentItem.radius
    }
}
