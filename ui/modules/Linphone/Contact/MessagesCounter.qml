import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: messagesCounter

  property int count
  property bool isComposing

  implicitHeight: counterIcon.height + MessagesCounterStyle.verticalMargins * 2
  implicitWidth: counterIcon.width + MessagesCounterStyle.horizontalMargins * 2

  Icon {
    id: counterIcon

    property int composingIndex: 0

    anchors.centerIn: parent

    icon: messagesCounter.isComposing
      ? ('chat_is_composing_' + counterIcon.composingIndex)
      : 'chat_count'
    iconSize: MessagesCounterStyle.iconSize.message
    visible: messagesCounter.count > 0 || messagesCounter.isComposing

    Icon {
      anchors {
        horizontalCenter: parent.right
        verticalCenter: parent.bottom
      }

      icon: 'chat_amount'
      iconSize: MessagesCounterStyle.iconSize.amount
      visible: messagesCounter.count > 0

      Text {
        anchors.centerIn: parent
        color: MessagesCounterStyle.text.color
        font.pointSize: MessagesCounterStyle.text.pointSize
        text: messagesCounter.count
      }
    }

    Timer {
      interval: 500
      repeat: true
      running: messagesCounter.isComposing

      onRunningChanged: {
        if (running) {
          counterIcon.composingIndex = 0
        }
      }

      onTriggered: counterIcon.composingIndex = (counterIcon.composingIndex + 1) % 4
    }
  }
}
