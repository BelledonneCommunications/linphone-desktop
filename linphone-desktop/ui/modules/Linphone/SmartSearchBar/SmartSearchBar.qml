import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

SearchBox {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property string interpretableSipAddress: SipAddressesModel.interpretUrl(
    searchBox.filter
  )

  // ---------------------------------------------------------------------------

  signal addContact (string sipAddress)
  signal launchChat (string sipAddress)
  signal launchCall (string sipAddress)
  signal launchVideoCall (string sipAddress)

  signal entryClicked (var entry)

  // ---------------------------------------------------------------------------

  onEnterPressed: interpretableSipAddress.length > 0 && searchBox.launchCall(interpretableSipAddress)

  // ---------------------------------------------------------------------------
  // Header.
  // ---------------------------------------------------------------------------

  header: MouseArea {
    height: {
      var height = SmartSearchBarStyle.header.addButtonHeight
      return defaultContact.visible ? height + searchBox.entryHeight : height
    }
    width: parent.width

    // Workaround to handle mouse.
    // Without it, the mouse can be given to items list when mouse is hover header.
    hoverEnabled: true

    Column {
      anchors.fill: parent

      spacing: 0

      // -----------------------------------------------------------------------
      // Default contact.
      // -----------------------------------------------------------------------

      Loader {
        id: defaultContact

        height: searchBox.entryHeight
        width: parent.width

        visible: interpretableSipAddress.length > 0

        sourceComponent: Rectangle {
          anchors.fill: parent
          color: SmartSearchBarStyle.entry.color.normal

          RowLayout {
            anchors {
              fill: parent
              rightMargin: SmartSearchBarStyle.entry.rightMargin
            }
            spacing: 0

            Contact {
              id: contact

              Layout.fillHeight: true
              Layout.fillWidth: true

              entry: ({
                sipAddress: interpretableSipAddress
              })
            }

            ActionBar {
              iconSize: SmartSearchBarStyle.entry.iconSize

              ActionButton {
                icon: 'video_call'
                onClicked: {
                  searchBox.hideMenu()
                  searchBox.launchVideoCall(interpretableSipAddress)
                }
              }

              ActionButton {
                icon: 'call'
                onClicked: {
                  searchBox.hideMenu()
                  searchBox.launchCall(interpretableSipAddress)
                }
              }

              ActionButton {
                icon: 'chat'
                onClicked: {
                  searchBox.hideMenu()
                  searchBox.launchChat(interpretableSipAddress)
                }
              }
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // Add contact button.
      // -----------------------------------------------------------------------

      MouseArea {
        id: addContactButton

        height: SmartSearchBarStyle.header.addButtonHeight
        width: parent.width

        onClicked: {
          searchBox.hideMenu()
          searchBox.addContact(interpretableSipAddress)
        }

        Rectangle {
          anchors.fill: parent
          color: parent.pressed
            ? SmartSearchBarStyle.header.color.pressed
            : SmartSearchBarStyle.header.color.normal

          Text {
            anchors {
              left: parent.left
              leftMargin: SmartSearchBarStyle.header.leftMargin
              verticalCenter: parent.verticalCenter
            }
            font {
              bold: true
              pointSize: SmartSearchBarStyle.header.text.fontSize
            }
            color: addContactButton.pressed
              ? SmartSearchBarStyle.header.text.color.pressed
              : SmartSearchBarStyle.header.text.color.normal
            text: qsTr('addContact')
          }

          Icon {
            anchors {
              right: parent.right
              rightMargin: SmartSearchBarStyle.header.rightMargin
              verticalCenter: parent.verticalCenter
            }
            icon: 'contact_add'
            iconSize: SmartSearchBarStyle.header.iconSize
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Entries.
  // ---------------------------------------------------------------------------

  delegate: Rectangle {
    id: sipAddressEntry

    color: SmartSearchBarStyle.entry.color.normal
    height: searchBox.entryHeight
    width: parent ? parent.width : 0

    Rectangle {
      id: indicator

      anchors.left: parent.left
      color: 'transparent'
      height: parent.height
      width: SmartSearchBarStyle.entry.indicator.width
    }

    MouseArea {
      id: mouseArea

      anchors.fill: parent
      hoverEnabled: true

      RowLayout {
        anchors {
          fill: parent
          rightMargin: SmartSearchBarStyle.entry.rightMargin
        }
        spacing: 0

        // -------------------------------------------------------------------
        // Contact or address info.
        // -------------------------------------------------------------------

        Contact {
          Layout.fillHeight: true
          Layout.fillWidth: true
          entry: $entry

          MouseArea {
            anchors.fill: parent

            cursorShape: containsMouse
              ? Qt.PointingHandCursor
              : Qt.ArrowCursor
            hoverEnabled: true

            onClicked: {
              searchBox.hideMenu()
              searchBox.entryClicked($entry)
            }
          }
        }

        // -------------------------------------------------------------------
        // Actions
        // -------------------------------------------------------------------

        ActionBar {
          iconSize: SmartSearchBarStyle.entry.iconSize

          ActionButton {
            icon: 'video_call'
            onClicked: {
              searchBox.hideMenu()
              searchBox.launchVideoCall($entry.sipAddress)
            }
          }

          ActionButton {
            icon: 'call'
            onClicked: {
              searchBox.hideMenu()
              searchBox.launchCall($entry.sipAddress)
            }
          }

          ActionButton {
            icon: 'chat'
            onClicked: {
              searchBox.hideMenu()
              searchBox.launchChat($entry.sipAddress)
            }
          }
        }
      }
    }

    // Separator.
    Rectangle {
      color: SmartSearchBarStyle.entry.separator.color
      height: SmartSearchBarStyle.entry.separator.height
      width: parent.width
    }

    // -------------------------------------------------------------------------

    states: State {
      when: mouseArea.containsMouse

      PropertyChanges {
        color: SmartSearchBarStyle.entry.color.hovered
        target: sipAddressEntry
      }

      PropertyChanges {
        color: SmartSearchBarStyle.entry.indicator.color
        target: indicator
      }
    }
  }
}
