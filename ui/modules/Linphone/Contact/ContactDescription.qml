import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Column {
  property alias username: username.text
  property string sipAddress

  property color sipAddressColor: ContactDescriptionStyle.sipAddress.color
  property color usernameColor: ContactDescriptionStyle.username.color
  property int horizontalTextAlignment

  // ---------------------------------------------------------------------------

  Text {
    id: username

    color: usernameColor
    elide: Text.ElideRight
    font.bold: true
    font.pointSize: ContactDescriptionStyle.username.pointSize
    height: parent.height / 2
    horizontalAlignment: horizontalTextAlignment
    verticalAlignment: Text.AlignBottom
    width: parent.width
  }

  Text {
    text: SipAddressesModel.cleanSipAddress(sipAddress)

    color: sipAddressColor
    elide: Text.ElideRight
    font.pointSize: ContactDescriptionStyle.sipAddress.pointSize
    height: parent.height / 2
    horizontalAlignment: horizontalTextAlignment
    verticalAlignment: Text.AlignTop
    width: parent.width
  }
}
