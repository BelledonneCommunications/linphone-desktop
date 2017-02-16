import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Column {
  default property alias _content: content.data
  property alias icon: icon.icon
  property alias title: title.text
  property alias description: description.text

  // ---------------------------------------------------------------------------

  spacing: CardBlockStyle.spacing
  width: CardBlockStyle.width

  Icon {
    id: icon

    iconSize: CardBlockStyle.icon.size
    height: CardBlockStyle.icon.size + CardBlockStyle.icon.bottomMargin
    width: parent.width
  }

  Column {
    width: parent.width
    spacing: CardBlockStyle.title.bottomMargin

    Text {
      id: title

      color: CardBlockStyle.title.color
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap

      font {
        bold: true
        pointSize: CardBlockStyle.title.fontSize
      }

      height: CardBlockStyle.title.height
      width: parent.width
    }

    Text {
      id: description

      color: CardBlockStyle.description.color
      elide: Text.ElideRight
      font.pointSize: CardBlockStyle.description.fontSize
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap

      height: CardBlockStyle.description.height
      width: parent.width
    }
  }

  // ---------------------------------------------------------------------------

  Item {
    id: content

    height: CardBlockStyle.content.height
    width: parent.width
  }
}
