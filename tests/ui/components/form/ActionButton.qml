import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================
// An animated small button with an image.
// ===================================================================

Button {
    property int iconSize
    property string icon

    // Ugly hack, use current size, ActionBar size,
    // or other parent height.
    height: iconSize || parent.iconSize || parent.height
    width: iconSize || parent.iconSize || parent.height

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: 'qrc:/imgs/' + parent.icon + '.svg'
    }
}
