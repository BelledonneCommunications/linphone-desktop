import QtQuick 2.7

Item {
    property alias backgroundColor: rectangle.color

    id: container
    implicitHeight: text.contentHeight + text.padding * 2
    width: parent.width - text.padding * 2

    Rectangle {
        id: rectangle
        height: parent.height
        radius: 4
        width: (
            text.contentWidth < parent.width
                ? text.contentWidth
                : parent.width
        ) + text.padding * 2
    }

    Text {
        anchors.left: container.left
        anchors.right: container.right
        padding: 8
        id: text
        text: $message
        wrapMode: Text.Wrap
    }
}
