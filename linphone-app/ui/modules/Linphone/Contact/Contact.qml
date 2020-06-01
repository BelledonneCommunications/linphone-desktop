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

  property bool displayUnreadMessageCount: false

  // A entry from `SipAddressesModel` or an `SipAddressObserver`.
  property var entry

  readonly property var _contact: entry.contact

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

      presenceLevel: entry.presenceStatus != null
        ? Presence.getPresenceLevel(entry.presenceStatus)
        : -1

      username: LinphoneUtils.getContactUsername(_contact || entry.sipAddress || entry.fullPeerAddress  || entry.peerAddress || '')
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.leftMargin: ContactStyle.spacing

      sipAddress: entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || ''
      username: avatar.username
    }

    ContactMessageCounter {
      Layout.alignment: Qt.AlignTop

      count: Number(entry.unreadMessageCount) + Number(entry.missedCallCount)
      isComposing: Boolean(entry.isComposing)

      visible: item.displayUnreadMessageCount
    }
  }
}
