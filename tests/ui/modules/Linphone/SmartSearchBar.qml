import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

// =============================================================================

SearchBox {
  id: searchBox

  header: Rectangle {
    color: '#4B5964'
    height: 40
    width: parent.width

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
    }
  }

  delegate: Rectangle {
    id: searchBoxEntry

    height: searchBox.entryHeight
    width: parent ? parent.width : 0

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
          rightMargin: 10
        }
        spacing: 0

        // ---------------------------------------------------------------------
        // Contact or address info
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
            onClicked: {
              searchBox.hideMenu()
              window.ensureCollapsed()
              window.setView('Conversation', {
                sipAddress: $entry.sipAddress
              })
            }
          }
        }
      }
    }

    Rectangle {
      color: '#CBCBCB'
      height: 1
      width: parent.width
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
