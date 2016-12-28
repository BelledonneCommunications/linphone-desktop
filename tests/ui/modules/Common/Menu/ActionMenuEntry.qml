import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Rectangle {
  id: entry

  property alias entryName: text.text

  signal clicked

  color: mouseArea.pressed
    ? ActionMenuStyle.entry.color.pressed
    : (mouseArea.containsMouse
       ? ActionMenuStyle.entry.color.hovered
       : ActionMenuStyle.entry.color.normal
      )
  height: parent.entryHeight
  width: parent.entryWidth

  Text {
    id: text

    anchors {
      left: parent.left
      leftMargin: ActionMenuStyle.entry.leftMargin
      right: parent.right
      rightMargin: ActionMenuStyle.entry.rightMargin
    }

    color: ActionMenuStyle.entry.text.color
    elide: Text.ElideRight
    font.pointSize: ActionMenuStyle.entry.text.fontSize
    height: parent.height
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    hoverEnabled: true

    onClicked: entry.clicked
  }
}
