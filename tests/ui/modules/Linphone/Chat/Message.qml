import QtQuick 2.7

// ===================================================================

Item {
  default property alias content: content.data
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
    id: text
    padding: 8
    text: $content
    wrapMode: Text.Wrap

    // Little fix. Text may disappear with scrolling.
    renderType: Text.NativeRendering
  }

  Item {
    anchors.left: rectangle.right
    id: content
  }
}
