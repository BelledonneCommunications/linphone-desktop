import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Rectangle {
  default property alias _content: content.data

  anchors.fill: parent
  color: TabContainerStyle.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Flickable {
      ScrollBar.vertical: ForceScrollBar {
        id: scrollBar
      }

      Layout.fillHeight: true
      Layout.fillWidth: true

      boundsBehavior: Flickable.StopAtBounds
      clip: true

      contentHeight: Utils.ensureArray(_content).reduce(function (acc, item) { return item.height }, 0, []) +
        TabContainerStyle.topMargin + TabContainerStyle.bottomMargin
      contentWidth: width

      Item {
        id: content

        anchors {
          left: parent.left
          leftMargin: TabContainerStyle.leftMargin
          right: parent.right
          rightMargin: TabContainerStyle.rightMargin
          top: parent.top
          topMargin: TabContainerStyle.topMargin
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: TabContainerStyle.separator.height

      color: TabContainerStyle.separator.color
      visible: scrollBar.visible
    }
  }
}
