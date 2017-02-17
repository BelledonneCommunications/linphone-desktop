import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      enabled: email.length && message.length
      text: qsTr('confirm')

      onClicked: exit(-1)
    }
  ]

  centeredButtons: true

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
      }
    }
  }
}
