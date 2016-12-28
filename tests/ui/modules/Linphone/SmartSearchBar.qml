import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

SearchBox {
  id: searchBox

  // ---------------------------------------------------------------------------

  signal addContact (string sipAddress)
  signal launchChat (string sipAddress)
  signal launchCall (string sipAddress)
  signal launchVideoCall (string sipAddress)

  // ---------------------------------------------------------------------------

  header: MouseArea {
    id: headerContent

    height: SmartSearchBarStyle.header.height
    width: parent.width

    onClicked: {
      searchBox.hideMenu()
      searchBox.addContact(searchBox.filter)
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
        color: headerContent.pressed
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

  // ---------------------------------------------------------------------------
  // Entries.
  // ---------------------------------------------------------------------------

  delegate: Rectangle {
    id: searchBoxEntry

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

        // ---------------------------------------------------------------------
        // Contact or address info.
        // ---------------------------------------------------------------------

        Contact {
          Layout.fillHeight: true
          Layout.fillWidth: true
          sipAddress: $entry.sipAddress
        }

        // ---------------------------------------------------------------------
        // Actions
        // ---------------------------------------------------------------------

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
        target: searchBoxEntry
      }

      PropertyChanges {
        color: SmartSearchBarStyle.entry.indicator.color
        target: indicator
      }
    }
  }
}
