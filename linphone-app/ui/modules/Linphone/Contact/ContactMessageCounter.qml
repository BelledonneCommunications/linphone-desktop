import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: messageCounter

  property alias count: counterIcon.count
  property var entry
  property bool isComposing: Boolean(entry && entry.composers && entry.composers.length > 0)
  property bool displayCounter: true

  implicitHeight: counterIcon.height + ContactMessageCounterStyle.verticalMargins * 2
  implicitWidth: counterIcon.width + ContactMessageCounterStyle.horizontalMargins * 2
  visible: count > 0 ?(entry.unreadMessagesCount !== null || entry.missedCallsCount !== null) && displayCounter:false

  MessageCounter {
    id: counterIcon

    property int composingIndex: 0

    anchors.centerIn: parent

    icon: messageCounter.isComposing
      ? ('chat_is_composing_' + counterIcon.composingIndex)
      : 'chat_count'
    visible: messageCounter.count > 0 || messageCounter.isComposing
    
    count: messageCounter.entry?Number(messageCounter.entry.unreadMessagesCount) + Number(messageCounter.entry.missedCallsCount):0

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
