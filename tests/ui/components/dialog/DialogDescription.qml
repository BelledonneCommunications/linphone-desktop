import QtQuick 2.7

Item {
    property alias text: description.text
    property alias fontSize: description.font.pointSize

    height: 90

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
