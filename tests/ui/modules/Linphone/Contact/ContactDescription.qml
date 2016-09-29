import QtQuick 2.7

import Linphone.Styles 1.0

// ===================================================================

Column {
  property alias sipAddress: sipAddress.text
  property alias username: username.text

  // Username.
  Text {
    id: username

    clip: true
    color: ContactDescriptionStyle.username.color
    font.bold: true
    font.pointSize: ContactDescriptionStyle.username.fontSize
    height: parent.height / 2
    verticalAlignment: Text.AlignBottom
    width: parent.width
  }

  // Sip address.
  Text {
    id: sipAddress

    clip: true
    color: ContactDescriptionStyle.sipAddress.color
    font.pointSize: ContactDescriptionStyle.sipAddress.fontSize
    height: parent.height / 2
    verticalAlignment: Text.AlignTop
    width: parent.width
  }
}
