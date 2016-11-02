import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// ===================================================================

ColumnLayout {
  spacing: 0

  // -----------------------------------------------------------------
  // Search Bar & actions.
  // -----------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: ContactsStyle.bar.height

    color: ContactsStyle.bar.color

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: ContactsStyle.bar.leftMargin
      anchors.rightMargin: ContactsStyle.bar.rightMargin

      spacing: 20

      TextField {
        Layout.fillWidth: true
        icon: 'filter'
        placeholderText: qsTr('searchContactPlaceholder')

        onTextChanged: {
          contacts.setFilterFixedString(text)
          contacts.invalidate()
        }
      }

      ExclusiveButtons {
        texts: [
          qsTr('selectAllContacts'),
          qsTr('selectConnectedContacts')
        ]

        onClicked: contacts.useConnectedFilter = (button === 1)
      }

      TextButtonB {
        text: qsTr('addContact')
        onClicked: window.setView('Contact')
      }
    }
  }

  // -----------------------------------------------------------------
  // Contacts list.
  // -----------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: ContactsStyle.backgroundColor

    ScrollableListView {
      anchors.fill: parent
      spacing: ContactsStyle.contacts.spacing

      model: ContactsListModel {
        id: contacts
      }

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
                  icon: 'video_call'
                  onClicked: CallsWindow.show()
                }

                ActionButton {
                  icon: 'call'
                  onClicked: CallsWindow.show()
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
