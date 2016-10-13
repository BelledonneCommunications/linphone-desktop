import Common 1.0
import Linphone 1.0

StartingCall {
  avatarImage: "qrc:/imgs/cat_contact.jpg"
  callType: 'INCOMING CALL'
  sipAddress: 'mister-meow@sip-linphone.org'
  username: 'Mister Meow'

  ActionBar {
    anchors.centerIn: parent
    iconSize: 40

    ActionButton {
      icon: 'cam'
    }

    ActionButton {
      icon: 'call'
    }

    ActionButton {
      icon: 'hangup'
    }
  }
}
