import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

Item {
  property alias actions: actionBar.data
  property alias image: avatar.image
  property alias presenceLevel: avatar.presenceLevel
  property alias sipAddress: description.sipAddress
  property alias sipAddressColor: description.sipAddressColor
  property alias username: avatar.username
  property alias usernameColor: description.usernameColor

  height: ContactStyle.height

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: ContactStyle.leftMargin
    anchors.rightMargin: ContactStyle.rightMargin
    spacing: ContactStyle.spacing

    Avatar {
      id: avatar

      Layout.preferredHeight: ContactStyle.contentHeight
      Layout.preferredWidth: ContactStyle.contentHeight
    }

    ContactDescription {
      id: description

      Layout.fillHeight: true
      Layout.fillWidth: true
      username: avatar.username
    }

    ActionBar {
      id: actionBar

      Layout.preferredHeight: ContactStyle.contentHeight
    }
  }
}
