import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import LinphoneUtils 1.0

// =============================================================================

RowLayout {
  implicitHeight: message.height
  spacing: 0

  Item {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: ChatStyle.entry.lineHeight
    Layout.preferredWidth: ChatStyle.entry.metaWidth

    Avatar {
      anchors.centerIn: parent
      height: ChatStyle.entry.message.incoming.avatarSize
      image: chat.sipAddressObserver.contact ? chat.sipAddressObserver.contact.vcard.avatar : ''
      username: LinphoneUtils.getContactUsername(chat.sipAddressObserver)
      width: ChatStyle.entry.message.incoming.avatarSize

      // The avatar is only visible for the first message of a incoming messages sequence.
      visible: {
        if (index <= 0) {
          return true // 1. First message, so visible.
        }

        var previousEntry = proxyModel.data(proxyModel.index(index - 1, 0))
        if (!previousEntry) {
          return true
        }

        // 2. Previous entry is a call event. => Visible.
        // 3. I have sent a message before my contact. => Visible.
        // 4. One hour between two incoming messages. => Visible.
        return previousEntry.type !== ChatModel.MessageEntry ||
          previousEntry.isOutgoing ||
          $chatEntry.timestamp.getTime() - previousEntry.timestamp.getTime() > 3600
      }
    }
  }

  Message {
    id: message

    Layout.fillWidth: true

    // Not a style. Workaround to avoid a 0 width.
    // Arbitrary value.
    Layout.minimumWidth: 1

    backgroundColor: ChatStyle.entry.message.incoming.backgroundColor
    color: ChatStyle.entry.message.incoming.text.color
    pointSize: ChatStyle.entry.message.incoming.text.pointSize

    ActionButton {
      height: ChatStyle.entry.lineHeight
      icon: 'delete'
      iconSize: ChatStyle.entry.deleteIconSize
      visible: isHoverEntry()

      onClicked: removeEntry()
    }
  }
}
