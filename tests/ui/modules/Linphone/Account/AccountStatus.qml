import QtQuick 2.7

import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Item {
  Column {
    anchors.fill: parent

    Text {
      clip: true
      color: AccountStatusStyle.username.color
      elide: Text.ElideRight
      font.bold: true
      font.pointSize: AccountStatusStyle.username.fontSize
      height: parent.height / 2
      text: AccountSettingsModel.username
      verticalAlignment: Text.AlignBottom
      width: parent.width
    }

    Text {
      color: AccountStatusStyle.sipAddress.color
      elide: Text.ElideRight
      font.pointSize: AccountStatusStyle.sipAddress.fontSize
      height: parent.height / 2
      text: AccountSettingsModel.sipAddress
      verticalAlignment: Text.AlignTop
      width: parent.width
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: Utils.openWindow('ManageAccounts', this)
  }
}
