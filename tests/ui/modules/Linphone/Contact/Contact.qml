import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
  id: item

  // ---------------------------------------------------------------------------

  property alias actions: actionBar.data
  property alias sipAddressColor: description.sipAddressColor
  property alias usernameColor: description.usernameColor
  property string sipAddress
  property var _contact: SipAddressesModel.mapSipAddressToContact(sipAddress)

  // ---------------------------------------------------------------------------

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
      image: _contact && _contact.vcard.avatar
      presenceLevel: _contact ? _contact.presenceLevel : Presence.White
      username: LinphoneUtils.getContactUsername(_contact || sipAddress)
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      sipAddress: item.sipAddress
      username: avatar.username
    }

    ActionBar {
      id: actionBar

      Layout.preferredHeight: ContactStyle.contentHeight
    }
  }
}
