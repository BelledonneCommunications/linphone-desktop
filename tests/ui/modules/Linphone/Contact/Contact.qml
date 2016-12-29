import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Rectangle {
  id: item

  // ---------------------------------------------------------------------------

  property alias actions: actionBar.data
  property alias sipAddressColor: description.sipAddressColor
  property alias usernameColor: description.usernameColor

  // Can be a SipAddress object of SipAddressesModel or just a string.
  property var sipAddress

  property var _contact: Utils.isObject(sipAddress)
    ? sipAddress.contact
    : SipAddressesModel.mapSipAddressToContact(sipAddress)

  // ---------------------------------------------------------------------------

  function _getSipAddress () {
    return item.sipAddress.sipAddress || item.sipAddress
  }

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
      presenceLevel: _contact ? _contact.presenceLevel : -1
      username: LinphoneUtils.getContactUsername(_contact || _getSipAddress())
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      sipAddress: _getSipAddress()
      username: avatar.username
    }

    ActionBar {
      id: actionBar

      Layout.preferredHeight: ContactStyle.contentHeight
    }
  }
}
