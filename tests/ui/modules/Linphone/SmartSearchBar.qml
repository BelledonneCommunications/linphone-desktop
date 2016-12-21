import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0

// =============================================================================

SearchBox {
  id: searchBox

  delegate: Rectangle {
    id: searchBoxEntry

    width: parent.width
    height: searchBox.entryHeight
    color: '#FFFFFF'

    Rectangle {
      id: indicator

      anchors.left: parent.left
      color: 'transparent'
      height: parent.height
      width: 5
    }

    MouseArea {
      id: mouseArea

      anchors.fill: parent
      hoverEnabled: true

      RowLayout {
        anchors {
          fill: parent
          leftMargin: 22
          rightMargin: 10
        }
        spacing: 15

        // ---------------------------------------------------------------------
        // Contact or address info
        // ---------------------------------------------------------------------

        Avatar {
          id: avatar
          Layout.preferredHeight: 30
          Layout.preferredWidth: 30
          image: $entry.vcard && $entry.vcard.avatar
          presenceLevel: $entry.presenceLevel != null ? $entry.presenceLevel : -1
          username: LinphoneUtils.getContactUsername($entry.sipAddress || $entry)
        }

        Text {
          Layout.fillWidth: true
          color: '#4B5964'
          elide: Text.ElideRight

          font {
            bold: true
            pointSize: 9
          }

          text: $entry.vcard ? $entry.vcard.username : $entry.sipAddress
        }

        // ---------------------------------------------------------------------
        // Actions
        // ---------------------------------------------------------------------

        ActionBar {
          iconSize: 36

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
            onClicked: window.setView('Conversation', {
              sipAddress: $entry.sipAddress || $entry.vcard.sipAddresses[0] // FIXME: Display menu if many addresses.
            })
          }
        }
      }
    }

    // -------------------------------------------------------------------------

    states: State {
      when: mouseArea.containsMouse

      PropertyChanges {
        color: '#D0D8DE'
        target: searchBoxEntry
      }

      PropertyChanges {
        color: '#FF5E00'
        target: indicator
      }
    }
  }
}
