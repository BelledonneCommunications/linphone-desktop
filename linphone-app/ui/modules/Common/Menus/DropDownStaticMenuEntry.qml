import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
  id: entry

  property alias entryName: text.text

  signal clicked

  color: mouseArea.pressed
    ? DropDownStaticMenuStyle.entry.color.pressed.color
    : (mouseArea.containsMouse
       ? DropDownStaticMenuStyle.entry.color.hovered.color
       : DropDownStaticMenuStyle.entry.color.normal.color
      )
  height: parent.entryHeight
  width: parent.entryWidth
  property int implicitWidth : text.implicitWidth + DropDownStaticMenuStyle.entry.leftMargin + DropDownStaticMenuStyle.entry.rightMargin + 5 // 5 = Elide width

  Text {
    id: text

    anchors {
      left: parent.left
      leftMargin: DropDownStaticMenuStyle.entry.leftMargin
      right: parent.right
      rightMargin: DropDownStaticMenuStyle.entry.rightMargin
    }

    color: DropDownStaticMenuStyle.entry.text.colorModel.color
    elide: Text.ElideRight
    font.pointSize: DropDownStaticMenuStyle.entry.text.pointSize

    height: parent.height
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent

    onClicked: entry.clicked()
  }
}
