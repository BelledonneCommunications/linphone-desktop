import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: accountStatus

  // ---------------------------------------------------------------------------

  signal clicked
  property alias cursorShape:mouseArea.cursorShape
  property alias betterIcon : presenceLevel.betterIcon

  // ---------------------------------------------------------------------------

  Row {
    anchors.fill: parent

    Column {
      //Layout.fillWidth: true
      //Layout.fillHeight: true
        anchors.fill:parent
        spacing: AccountStatusStyle.verticalSpacing

      Row {
        height: parent.height / 2
        spacing: AccountStatusStyle.horizontalSpacing
        //width: parent.width

        Item {
          //Layout.alignment: Qt.AlignBottom
         //Layout.bottomMargin: AccountStatusStyle.presenceLevel.bottomMargin
          //Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
          //Layout.preferredWidth: AccountStatusStyle.presenceLevel.size
          height: AccountStatusStyle.presenceLevel.size
          width: AccountStatusStyle.presenceLevel.size
          anchors.bottom:parent.bottom
          anchors.bottomMargin: AccountStatusStyle.presenceLevel.bottomMargin

          PresenceLevel {
            id:presenceLevel
            anchors.fill: parent
            level: OwnPresenceModel.presenceStatus===Presence.Offline?Presence.White:( SettingsModel.rlsUriEnabled ? OwnPresenceModel.presenceLevel : Presence.Green)
            visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateRegistered
          }

          BusyIndicator {
            anchors.fill: parent
            running: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateInProgress
          }

          Icon {
            iconSize: parent.width
            icon: 'generic_error'
            visible: AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNotRegistered || AccountSettingsModel.registrationState === AccountSettingsModel.RegistrationStateNoProxy
            TooltipArea{
                text : 'Not Registered'
            }
          }
        }

        Text {
          id:username
          anchors.bottom:parent.bottom
          
          //Layout.fillHeight: true
          //Layout.fillWidth: true
          color: AccountStatusStyle.username.color
          elide: Text.ElideRight
          font.bold: true
          font.pointSize: AccountStatusStyle.username.pointSize
          text: AccountSettingsModel.username
          verticalAlignment: Text.AlignBottom
        }
        Item {
           // Layout.bottomMargin: -AccountStatusStyle.presenceLevel.bottomMargin
            //Layout.preferredHeight: AccountStatusStyle.presenceLevel.size
            //Layout.preferredWidth: AccountStatusStyle.presenceLevel.size
            height: AccountStatusStyle.messageCounter.size
            width: AccountStatusStyle.messageCounter.size
            anchors.bottom:parent.bottom
            anchors.bottomMargin: AccountStatusStyle.messageCounter.bottomMargin
          MessageCounter {
            id: messageCounter
            //iconSize: parent.height
            anchors.fill: parent
            count: CoreManager.eventCount
          }
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

    
  }

  MouseArea {
    id:mouseArea
    anchors.fill: parent

    onClicked: accountStatus.clicked()
  }
}
