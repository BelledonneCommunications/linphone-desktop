import QtQuick 2.7
import QtQuick.Layouts 1.3

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

  height: InviteFriendsStyle.height
  width: InviteFriendsStyle.width

  minimumHeight: InviteFriendsStyle.height
  minimumWidth: InviteFriendsStyle.width

  // ---------------------------------------------------------------------------

  ColumnLayout {
    anchors {
      fill: parent
      leftMargin: InviteFriendsStyle.leftMargin
      rightMargin: InviteFriendsStyle.rightMargin
    }

    spacing: InviteFriendsStyle.spacing

    Column {
      Layout.fillWidth: true
      spacing: InviteFriendsStyle.input.spacing

      Text {
        color: InviteFriendsStyle.input.legend.color
        elide: Text.ElideRight

        font {
          bold: true
          pointSize: InviteFriendsStyle.input.legend.fontSize
        }

        text: qsTr('enterEmailLabel')
      }

      TextField {
        id: email

        inputMethodHints: Qt.ImhEmailCharactersOnly
        width: parent.width
      }
    }

    ColumnLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true
      spacing: InviteFriendsStyle.input.spacing

      Text {
        color: InviteFriendsStyle.input.legend.color
        elide: Text.ElideRight

        font {
          bold: true
          pointSize: InviteFriendsStyle.input.legend.fontSize
        }

        text: qsTr('messageLabel')
      }

      TextAreaField {
        id: message

        Layout.fillHeight: true
        Layout.fillWidth: true

        text: qsTr('defaultMessage')
      }
    }
  }
}
