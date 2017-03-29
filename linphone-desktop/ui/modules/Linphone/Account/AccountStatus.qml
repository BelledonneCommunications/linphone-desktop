import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: accountStatus

  // ---------------------------------------------------------------------------

  readonly property var _account: AccountSettingsModel

  signal clicked

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    RowLayout {
      height: parent.height / 2
      spacing: AccountStatusStyle.horizontalSpacing
      width: parent.width

      PresenceLevel {
        Layout.alignment: Qt.AlignBottom
        Layout.bottomMargin: AccountStatusStyle.presenceLevel.bottomMargin
        Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
        Layout.preferredWidth: AccountStatusStyle.presenceLevel.size
        level: OwnPresenceModel.presenceLevel
      }

      Text {
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: AccountStatusStyle.username.color
        elide: Text.ElideRight
        font.bold: true
        font.pointSize: AccountStatusStyle.username.fontSize
        text: accountStatus._account.username
        verticalAlignment: Text.AlignBottom
      }
    }

    Text {
      color: AccountStatusStyle.sipAddress.color
      elide: Text.ElideRight
      font.pointSize: AccountStatusStyle.sipAddress.fontSize
      height: parent.height / 2
      text: accountStatus._account.sipAddress
      verticalAlignment: Text.AlignTop
      width: parent.width
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: containsMouse
      ? Qt.PointingHandCursor
      : Qt.ArrowCursor
    hoverEnabled: true

    onClicked: accountStatus.clicked()
  }
}
