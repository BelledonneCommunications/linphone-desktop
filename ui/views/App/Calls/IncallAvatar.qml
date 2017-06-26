import QtQuick 2.7

import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// =============================================================================

Avatar {
  property var call

  readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(call.sipAddress)
  readonly property var _username: LinphoneUtils.getContactUsername(_sipAddressObserver)

  backgroundColor: CallStyle.container.avatar.backgroundColor
  foregroundColor: call.status === CallModel.CallStatusPaused
    ? CallStyle.container.pause.color
    : 'transparent'

  image: {
    var contact = _sipAddressObserver.contact
    return contact && contact.vcard.avatar
  }

  username: call.status === CallModel.CallStatusPaused ? '' : _username

  Text {
    anchors.fill: parent
    color: CallStyle.container.pause.text.color

    // `|| 1` => `pointSize` must be greater than 0.
    font.pointSize: (width / CallStyle.container.pause.text.pointSizeFactor) || 1

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    text: '&#9616;&nbsp;&#9612;'
    textFormat: Text.RichText
    visible: call.status === CallModel.CallStatusPaused
  }
}
