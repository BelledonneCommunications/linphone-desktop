import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0
import LinphoneUtils 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
  id: item

  // ---------------------------------------------------------------------------

  property alias sipAddressColor: description.sipAddressColor
  property alias usernameColor: description.usernameColor

  property bool displayUnreadMessagesCount: false

  property var entry

  property var _contact: entry.contact

  // ---------------------------------------------------------------------------

  color: 'transparent' // No color by default.
  height: ContactStyle.height

  RowLayout {
    anchors {
      fill: parent
      leftMargin: ContactStyle.leftMargin
      rightMargin: ContactStyle.rightMargin
    }
    spacing: 0

    Avatar {
      id: avatar

      Layout.preferredHeight: ContactStyle.contentHeight
      Layout.preferredWidth: ContactStyle.contentHeight
      image: _contact && _contact.vcard.avatar
      presenceLevel: _contact ? _contact.presenceLevel : -1
      username: LinphoneUtils.getContactUsername(_contact || entry.sipAddress)
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.leftMargin: ContactStyle.spacing

      sipAddress: entry.sipAddress
      username: avatar.username
    }

    MessagesCounter {
      Layout.alignment: Qt.AlignTop

      count: entry.unreadMessagesCount || 0
      visible: displayUnreadMessagesCount && entry.unreadMessagesCount > 0
    }
  }
}
