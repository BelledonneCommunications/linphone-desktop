import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: messagesCounter

  property int count

  implicitHeight: counterIcon.height + MessagesCounterStyle.verticalMargins * 2
  implicitWidth: counterIcon.width + MessagesCounterStyle.horizontalMargins * 2

  Icon {
    id: counterIcon

    anchors.centerIn: parent

    icon: 'chat_count'
    iconSize: MessagesCounterStyle.iconSize.message

    Icon {
      anchors {
        horizontalCenter: parent.right
        verticalCenter: parent.bottom
      }

      icon: 'chat_amount'
      iconSize: MessagesCounterStyle.iconSize.amount

      Text {
        anchors.centerIn: parent
        color: MessagesCounterStyle.text.color
        font.pointSize: MessagesCounterStyle.text.fontSize
        text: messagesCounter.count
      }
    }
  }
}
