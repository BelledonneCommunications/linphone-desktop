import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

RowLayout {
  implicitHeight: message.height
  spacing: 0

  Message {
    id: message

    Layout.fillWidth: true
    backgroundColor: ChatStyle.entry.message.outgoing.backgroundColor
    color: ChatStyle.entry.message.outgoing.text.color
    fontSize: ChatStyle.entry.message.outgoing.text.fontSize

    Row {
      spacing: ChatStyle.entry.message.extraContent.spacing

      Icon {
        height: ChatStyle.entry.lineHeight
        icon: 'chat_send'
        iconSize: ChatStyle.entry.message.outgoing.sendIconSize
      }

      ActionButton {
        height: ChatStyle.entry.lineHeight
        icon: 'delete'
        iconSize: ChatStyle.entry.deleteIconSize
        visible: isHoverEntry()

        onClicked: deleteEntry()
      }
    }
  }
}
