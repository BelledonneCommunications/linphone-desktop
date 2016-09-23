import QtQuick 2.7

import 'qrc:/ui/style'

// ===================================================================
// Description content used by dialogs.
// ===================================================================

Item {
    property alias text: description.text

    height: text ? DialogStyle.description.height : DialogStyle.description.minHeight

    Text {
        id: description

        anchors.fill: parent
        anchors.leftMargin: DialogStyle.leftMargin
        anchors.rightMargin: DialogStyle.rightMargin
        font.pointSize: DialogStyle.description.fontSize
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }
}
