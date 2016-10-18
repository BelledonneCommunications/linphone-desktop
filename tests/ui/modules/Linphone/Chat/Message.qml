import QtQuick 2.7

// ===================================================================

Item {
  id: container

  default property alias content: content.data
  property alias backgroundColor: rectangle.color

  implicitHeight: text.contentHeight + text.padding * 2

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
    id: text

    anchors.left: container.left
    anchors.right: container.right
    padding: 8
    text: $content
    wrapMode: Text.Wrap

    // Little fix. Text may disappear with scrolling.
    renderType: Text.NativeRendering
  }

  Item {
    id: content

    anchors.left: rectangle.right
  }
}
