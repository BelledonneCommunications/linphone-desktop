import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

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

  Item {
    anchors.fill: parent

    // TODO: Compute list max.
    ScrollableListView {
      id: accounts

      anchors.fill: parent

      // TODO: Remove, use C++ model instead.
      model: model1

      delegate: Item {
        function isDefaultAccount () {
          return accounts.currentIndex === index
        }

        height: 34
        width: parent.width

        Rectangle {
          anchors.fill: parent
          color: isDefaultAccount() ? '#EAEAEA' : 'transparent'
          id: accountLine

          RowLayout {
            anchors.fill: parent
            spacing: 15
            anchors.leftMargin: 15
            anchors.rightMargin: 15

            // Default account.
            Item {
              Layout.fillHeight: parent.height
              Layout.preferredWidth: 20

              Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: isDefaultAccount() ? 'qrc:/imgs/valid.svg' : ''
              }
            }

            // Sip account.
            Item {
              Layout.fillHeight: parent.height
              Layout.fillWidth: true

              Text {
                anchors.fill: parent
                clip: true
                color: '#59575A'
                text: sipAddress;
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: accounts.currentIndex = index
                }
              }
            }

            // Presence.
            Item {
              Layout.fillHeight: parent.height
              Layout.preferredWidth: 20

              Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: 'qrc:/imgs/led_' + presence + '.svg'
              }
            }

            // Update presence.
            Item {
              Layout.fillHeight: parent.height
              Layout.preferredWidth: 160

              TransparentComboBox {
                anchors.fill: parent
                model: model2
                textRole: 'key'
              }
            }
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
      presence: 'connected'
      sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
    }
    ListElement {
      presence: 'connected'
      sipAddress: 'toto.lala.sip.linphone.org'
    }
    ListElement {
      presence: 'disconnected'
      sipAddress: 'machin.truc.sip.linphone.org'
    }
    ListElement {
      presence: 'absent'
      sipAddress: 'hey.listen.sip.linphone.org'
    }
    ListElement {
      presence: 'do_not_disturb'
      sipAddress: 'valentin.cognito.sip.linphone.org'
    }
    ListElement {
      presence: 'do_not_disturb'
      sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      presence: 'disconnected'
      sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      presence: 'connected'
      sipAddress: 'nsa.sip.linphone.org'
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
