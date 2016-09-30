import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Linphone 1.0
import Utils 1.0

ColumnLayout {
  spacing: 2

  // Search bar.
  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 50
    anchors.left: parent.left
    anchors.leftMargin: 18
    anchors.right: parent.right
    anchors.rightMargin: 18

    RowLayout {
      anchors.verticalCenter: parent.verticalCenter
      height: 30
      spacing: 20
      width: parent.width

      // TODO: Replace by top-level component.
      TextField {
        Layout.fillWidth: true
        background: Rectangle {
          color: '#EAEAEA'
          implicitHeight: 30
        }
        placeholderText: qsTr('searchContactPlaceholder')

        Component.onCompleted: ContactsListModel.setFilterRegExp('')

        onTextChanged: ContactsListModel.setFilterRegExp(text)
      }

      ExclusiveButtons {
        texts: [
          qsTr('selectAllContacts'),
          qsTr('selectConnectedContacts')
        ]
      }

      TextButtonB {
        text: qsTr('addContact')

        onClicked: window.setView('Contact')
      }
    }
  }

  // Contacts list.
  Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: '#F5F5F5'

    ScrollableListView {
      anchors.fill: parent
      spacing: 2

      model: ContactsListModel

      delegate: Rectangle {
        id: contact

        color: '#FFFFFF'
        height: 50
        width: parent.width

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true

          onEntered: contact.state = 'hover'
          onExited: contact.state = ''
        }

        Item {
          anchors.verticalCenter: parent.verticalCenter
          height: 30
          width: parent.width

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 25
            spacing: 15

            // Avatar.
            Avatar {
              Layout.fillHeight: parent.height
              Layout.preferredWidth: 30
              image: $contact.avatar
              username: $contact.username
            }

            // Presence.
            Item {
              Layout.fillHeight: parent.height
              Layout.preferredWidth: 20

              PresenceLevel {
                anchors.fill: parent
                level: $contact.presenceLevel
              }
            }

            // Username.
            Text {
              Layout.fillHeight: parent.height
              Layout.fillWidth: true
              clip: true
              color: '#5A585B'
              font.bold: true
              text: $contact.username
              verticalAlignment: Text.AlignVCenter
            }

            // Actions.
            Row {
              id: actions

              Layout.fillHeight: true
              spacing: 50
              visible: false

              ActionBar {
                iconSize: parent.height

                ActionButton {
                  icon: 'cam'
                }

                ActionButton {
                  icon: 'call'
                }

                ActionButton {
                  icon: 'chat'

                  onClicked: window.setView('Conversation')
                }
              }

              ActionButton {
                iconSize: parent.height
                icon: 'delete'

                onClicked: Utils.openConfirmDialog(contact, {
                  descriptionText: qsTr('removeContactDescription'),
                  exitHandler: function (status) {
                    console.log('remove contact', status)
                  },
                  title: qsTr('removeContactTitle')
                })
              }
            }
          }
        }

        states: State {
          name: 'hover'
          PropertyChanges { target: contact; color: '#D1D1D1' }
          PropertyChanges { target: actions; visible: true }
        }
      }
    }
  }
}
