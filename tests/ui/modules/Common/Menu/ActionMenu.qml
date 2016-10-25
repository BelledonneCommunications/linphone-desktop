import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// ===================================================================
// Basic actions menu.
// ===================================================================

ColumnLayout {
  id: menu

  signal clicked (int entry)

  spacing: ActionMenuStyle.spacing

  property int entryHeight
  property int entryWidth
  property var entries

  Repeater {
    model: entries

    Rectangle {
      color: ActionMenuStyle.entry.color
      height: menu.entryHeight
      width: menu.entryWidth

      Text {
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
        text: modelData
        verticalAlignment: Text.AlignVCenter
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: menu.clicked(index)
      }
    }
  }
}
