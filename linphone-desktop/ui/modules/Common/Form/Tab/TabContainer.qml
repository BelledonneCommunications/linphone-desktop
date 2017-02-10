import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Rectangle {
  default property alias _content: content.data

  anchors.fill: parent
  color: TabContainerStyle.color

  Item {
    id: content

    anchors {
      fill: parent

      bottomMargin: TabContainerStyle.bottomMargin
      leftMargin: TabContainerStyle.leftMargin
      rightMargin: TabContainerStyle.rightMargin
      topMargin: TabContainerStyle.topMargin
    }
  }
}
