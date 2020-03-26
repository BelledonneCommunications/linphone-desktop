import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.ItemDelegate {
  id: item

  property var container
  property var flattenedModel
  property var itemIcon

  default property alias _content: content.data

  hoverEnabled: true

  background: Rectangle {
    color: item.hovered
      ? CommonItemDelegateStyle.color.hovered
      : CommonItemDelegateStyle.color.normal

    Rectangle {
      anchors.left: parent.left
      color: CommonItemDelegateStyle.indicator.color

      height: parent.height
      width: CommonItemDelegateStyle.indicator.width

      visible: item.hovered
    }

    Rectangle {
      anchors.bottom: parent.bottom
      color: CommonItemDelegateStyle.separator.color

      height: CommonItemDelegateStyle.separator.height
      width: parent.width

      visible: container.count !== index + 1
    }
  }

  contentItem: RowLayout {
    spacing: CommonItemDelegateStyle.contentItem.spacing
    width: item.width

    Icon {
      icon: item.itemIcon
      iconSize: CommonItemDelegateStyle.contentItem.iconSize

      visible: icon.length > 0
    }

    Text {
      Layout.fillWidth: true

      color: CommonItemDelegateStyle.contentItem.text.color
      elide: Text.ElideRight

      font {
        bold: container.currentIndex === index
        pointSize: CommonItemDelegateStyle.contentItem.text.pointSize
      }

      text: item.flattenedModel[container.textRole] || modelData
    }

    Item {
      id: content

      Layout.preferredWidth: CommonItemDelegateStyle.contentItem.iconSize
      Layout.preferredHeight: CommonItemDelegateStyle.contentItem.iconSize
    }
  }
}
