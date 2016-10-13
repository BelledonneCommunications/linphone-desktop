import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

StartingCall {
  avatarImage: "qrc:/imgs/cat_contact.jpg"
  callType: 'OUTGOING CALL'
  sipAddress: 'mister-meow@sip-linphone.org'
  username: 'Mister Meow'

  RowLayout {
    anchors.fill: parent
    spacing: 0

    ActionBar {
      iconSize: 40

      ActionButton {
        icon: 'micro'
      }

      ActionButton {
        icon: 'speaker'
      }

      ActionButton {
        icon: 'cam'
      }
    }

    // TODO: Cam.
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    ActionBar {
      iconSize: 40

      ActionButton {
        icon: 'hangup'
      }

      ActionButton {
        icon: 'chat'
      }
    }
  }
}
