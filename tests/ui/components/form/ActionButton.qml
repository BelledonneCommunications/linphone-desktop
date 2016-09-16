import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/image'

// ===================================================================
// An animated small button with an image.
// ===================================================================

Button {
    property int iconSize
    property alias icon: icon.icon

    // Ugly hack, use current size, ActionBar size,
    // or other parent height.
    height: iconSize || parent.iconSize || parent.height
    width: iconSize || parent.iconSize || parent.height

    Icon {
        anchors.fill: parent
        id: icon
    }
}
