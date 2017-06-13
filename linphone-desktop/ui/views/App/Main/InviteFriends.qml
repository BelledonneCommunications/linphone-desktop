import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  color: InviteFriendsStyle.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    Item {
      id: content

      Layout.fillHeight: true
      Layout.fillWidth: true

      Form {
        anchors.centerIn: parent
        orientation: Qt.Vertical
        title: qsTr('inviteFriendsTitle')
        width: InviteFriendsStyle.width

        FormLine {
          FormGroup {
            label: qsTr('enterEmailLabel')

            TextField {
              id: email

              inputMethodHints: Qt.ImhEmailCharactersOnly
              width: parent.width
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('messageLabel')

            TextAreaField {
              id: message

              height: InviteFriendsStyle.message.height
              text: qsTr('defaultMessage').replace('%1', AccountSettingsModel.username)
            }
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Buttons.
    // -------------------------------------------------------------------------

    Row {
      id: buttons

      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: InviteFriendsStyle.buttons.bottomMargin

      spacing: InviteFriendsStyle.buttons.spacing

      TextButtonA {
        text: qsTr('cancel')

        onClicked: window.setView('Home')
      }

      TextButtonB {
        enabled: email.length && message.length
        text: qsTr('confirm')

        onClicked: {
          Qt.openUrlExternally(
            'mailto:' + encodeURIComponent(email.text) +
            '?subject=' + encodeURIComponent(qsTr('defaultSubject')) +
            '&body=' + encodeURIComponent(
              message.text + '\n\n' + qsTr('forcedMessage').replace(/%1/g, CoreManager.downloadUrl)
            )
          )

          window.setView('Home')
        }
      }
    }
  }
}
