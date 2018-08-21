import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: messageCounter

  property int count
  property bool isComposing

  implicitHeight: counterIcon.height + MessageCounterStyle.verticalMargins * 2
  implicitWidth: counterIcon.width + MessageCounterStyle.horizontalMargins * 2

  Icon {
    id: counterIcon

    property int composingIndex: 0

    anchors.centerIn: parent

    icon: messageCounter.isComposing
      ? ('chat_is_composing_' + counterIcon.composingIndex)
      : 'chat_count'
    iconSize: MessageCounterStyle.iconSize.message
    visible: messageCounter.count > 0 || messageCounter.isComposing

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

    Timer {
      interval: 500
      repeat: true
      running: messageCounter.isComposing

      onRunningChanged: {
        if (running) {
          counterIcon.composingIndex = 0
        }
      }

      onTriggered: counterIcon.composingIndex = (counterIcon.composingIndex + 1) % 4
    }
  }
}
