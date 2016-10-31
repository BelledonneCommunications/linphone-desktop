import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

DialogPlus {
  descriptionText: qsTr('manageAccountsDescription')
  minimumHeight: 328
  minimumWidth: 480
  title: qsTr('manageAccountsTitle')

  buttons: TextButtonA {
    text: qsTr('validate')
    onClicked: exit(0)
  }

  // TODO: Compute list max.
  ScrollableListView {
    id: accounts

    anchors.fill: parent
    model: model1 // TMP

    delegate: Item {
      function isDefaultAccount () {
        return accounts.currentIndex === index
      }

      height: 34
      width: parent.width

      Rectangle {
        anchors.fill: parent
        color: isDefaultAccount() ? '#EAEAEA' : 'transparent'

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 15
          anchors.rightMargin: 15
          spacing: 15

          // Is default account?
          Icon {
            Layout.preferredHeight: 20
            Layout.preferredWidth: 20
            icon: isDefaultAccount() ? 'valid' : ''
          }

          // Sip account.
          Text {
            Layout.fillWidth: true
            clip: true
            color: '#59575A'
            text: $sipAddress
            verticalAlignment: Text.AlignVCenter

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: accounts.currentIndex = index
            }
          }

          // Presence.
          Icon {
            Layout.preferredHeight: 20
            Layout.preferredWidth: 20
            icon: 'led_' + $presence
          }

          // Update presence.
          TransparentComboBox {
            Layout.preferredWidth: 160
            model: model2 // TMP.
            textRole: 'key'
          }
        }
      }
    }
  }

  // =================================================================
  // TMP
  // =================================================================

  ListModel {
    id: model1

    ListElement {
      $presence: 'connected'
      $sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'toto.lala.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'machin.truc.sip.linphone.org'
    }
    ListElement {
      $presence: 'absent'
      $sipAddress: 'hey.listen.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'valentin.cognito.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
  }

  ListModel {
    id: model2

    ListElement { key: qsTr('onlinePresence'); value: 1 }
    ListElement { key: qsTr('busyPresence'); value: 2 }
    ListElement { key: qsTr('beRightBackPresence'); value: 3 }
    ListElement { key: qsTr('awayPresence'); value: 4 }
    ListElement { key: qsTr('onThePhonePresence'); value: 5 }
    ListElement { key: qsTr('outToLunchPresence'); value: 6 }
    ListElement { key: qsTr('doNotDisturbPresence'); value: 7 }
    ListElement { key: qsTr('movedPresence'); value: 8 }
    ListElement { key: qsTr('usingAnotherMessagingServicePresence'); value: 9 }
    ListElement { key: qsTr('offlinePresence'); value: 10 }
  }
}
