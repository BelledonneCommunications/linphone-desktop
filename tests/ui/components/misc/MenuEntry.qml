import QtQuick 2.7

Rectangle {
    property alias entryName: text.text
    property bool isSelected

    color: isSelected ? '#434343' : '#8E8E8E'

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Image {
            height: parent.height
            width: 30
        }

        Text {
            color: '#FFFFFF'
            font.pointSize: 13
            height: parent.height
            id: text
            verticalAlignment: Text.AlignVCenter
        }

        Image {
            height: parent.height
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { } // TODO.
    }
}
