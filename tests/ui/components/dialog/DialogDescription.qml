import QtQuick 2.7

// ===================================================================
// Description content used by dialogs.
// ===================================================================

Item {
    property alias text: description.text

    height: text ? 90 : 25

    Text {
        anchors.fill: parent
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        font.pointSize: 12
        id: description
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }
}
