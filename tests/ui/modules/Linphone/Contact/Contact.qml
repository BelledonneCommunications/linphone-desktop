import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Rectangle {
  id: item

  property alias actions: actionBar.data
  property alias sipAddressColor: description.sipAddressColor
  property alias usernameColor: description.usernameColor

  // Can be a contact object or just a sip address.
  property var contact

  // Override contact.sipAddress if used.
  property var sipAddress

  color: 'transparent' // No color by default.
  height: ContactStyle.height

  RowLayout {
    anchors {
      fill: parent
      leftMargin: ContactStyle.leftMargin
      rightMargin: ContactStyle.rightMargin
    }
    spacing: ContactStyle.spacing

    Avatar {
      id: avatar

      Layout.preferredHeight: ContactStyle.contentHeight
      Layout.preferredWidth: ContactStyle.contentHeight
      image: contact.avatar || ''
      presenceLevel: contact.presenceLevel || Presence.White
      username: Utils.isString(contact)
        ? contact.substring(4, contact.indexOf('@')) // 4 = length("sip:")
        : contact.username
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      sipAddress: Utils.isString(contact)
        ? contact
        : item.sipAddress || contact.sipAddress
      username: avatar.username
    }

    ActionBar {
      id: actionBar

      Layout.preferredHeight: ContactStyle.contentHeight
    }
  }
}
