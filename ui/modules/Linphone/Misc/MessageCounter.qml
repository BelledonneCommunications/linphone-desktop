import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Icon {
  id: messageCounter

  property int count: 0

  icon: 'chat_count'
  iconSize: MessageCounterStyle.iconSize.message
  visible: messageCounter.count > 0

  Icon {
    anchors {
      horizontalCenter: parent.right
      verticalCenter: parent.bottom
    }

    icon: 'chat_amount'
    iconSize: MessageCounterStyle.iconSize.amount
    visible: messageCounter.count > 0

    Text {
      anchors.centerIn: parent
      color: MessageCounterStyle.text.color
      font.pointSize: MessageCounterStyle.text.pointSize
      text: messageCounter.count
    }
  }
}
