import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(-1)
    },
    TextButtonB {
      enabled: email.length && message.length
      text: qsTr('confirm')

      onClicked: {
        Qt.openUrlExternally(
          'mailto:' + encodeURIComponent(email.text) +
          '?subject=' + encodeURIComponent(qsTr('defaultSubject')) +
          '&body=' + encodeURIComponent(message.text)
        )

        exit(0)
      }
    }
  ]

  centeredButtons: true
  title: qsTr('inviteFriendsTitle')

  height: InviteFriendsWindowStyle.height
  width: InviteFriendsWindowStyle.width

  maximumHeight: InviteFriendsWindowStyle.height
  maximumWidth: InviteFriendsWindowStyle.width

  minimumHeight: InviteFriendsWindowStyle.height
  minimumWidth: InviteFriendsWindowStyle.width

  // ---------------------------------------------------------------------------

  Form {
    anchors {
      fill: parent
      leftMargin: InviteFriendsWindowStyle.leftMargin
      rightMargin: InviteFriendsWindowStyle.rightMargin
    }

    orientation: Qt.Vertical

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

          height: InviteFriendsWindowStyle.message.height
          text: qsTr('defaultMessage')
        }
      }
    }
  }
}
