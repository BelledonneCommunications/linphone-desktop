import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: accountStatus

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    RowLayout {
      height: parent.height / 2
      spacing: AccountStatusStyle.horizontalSpacing
      width: parent.width

      Item {
        Layout.alignment: Qt.AlignBottom
        Layout.bottomMargin: AccountStatusStyle.presenceLevel.bottomMargin
        Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
        Layout.preferredWidth: AccountStatusStyle.presenceLevel.size

        PresenceLevel {
          anchors.fill: parent
          level: OwnPresenceModel.presenceLevel
          visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateRegistered
        }

        BusyIndicator {
          anchors.fill: parent
          running: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateInProgress
        }

        Icon {
          iconSize: parent.width
          icon: 'generic_error'
          visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNotRegistered
        }
      }

      Text {
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: AccountStatusStyle.username.color
        elide: Text.ElideRight
        font.bold: true
        font.pointSize: AccountStatusStyle.username.pointSize
        text: AccountSettingsModel.username
        verticalAlignment: Text.AlignBottom
      }
    }

    Text {
      color: AccountStatusStyle.sipAddress.color
      elide: Text.ElideRight
      font.pointSize: AccountStatusStyle.sipAddress.pointSize
      height: parent.height / 2
      text: AccountSettingsModel.sipAddress
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
