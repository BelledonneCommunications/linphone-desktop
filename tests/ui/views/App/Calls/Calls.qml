import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

Window {
  id: window

  // ---------------------------------------------------------------------------

  function launchAudioCall (sipAddress) {
    window.show()

  }

  function launchVideoCall (sipAddress) {
    window.show()

  }

  // ---------------------------------------------------------------------------

  minimumHeight: 480
  minimumWidth: 960

  Paned {
    anchors.fill: parent
    defaultChildAWidth: 250
    maximumLeftLimit: 250
    minimumLeftLimit: 110

    // ---------------------------------------------------------------
    // Calls list.
    // ---------------------------------------------------------------

    childA: Rectangle {
      anchors.fill: parent
      color: '#FFFFFF'

      ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 60

          LinearGradient {
            anchors.fill: parent

            start: Qt.point(0, 0)
            end: Qt.point(0, height)

            gradient: Gradient {
              GradientStop { position: 0.0; color: '#FFFFFF' }
              GradientStop { position: 1.0; color: '#E3E3E3' }
            }
          }

          ActionBar {
            anchors {
              left: parent.left
              leftMargin: 10
              verticalCenter: parent.verticalCenter
            }

            iconSize: 40

            ActionButton {
              icon: 'new_call'
            }

            ActionButton {
              icon: 'new_conference'
            }
          }
        }

        Calls {
          Layout.fillHeight: true
          Layout.fillWidth: true

          model: CallsListModel
        }
      }
    }

    // ---------------------------------------------------------------
    // Content.
    // ---------------------------------------------------------------

    childB: Paned {
      anchors.fill: parent
      closingEdge: Qt.RightEdge
      defaultClosed: true
      minimumLeftLimit: 395
      minimumRightLimit: 300
      resizeAInPriority: true

      // Call.
      childA: Incall {
        anchors.fill: parent
        sipAddress: 'sip:erwan.croze@sip.linphone.org'
        isVideoCall: true
      }

      // Chat.
      childB: Chat {
        anchors.fill: parent
        proxyModel: ChatProxyModel {
          id: chatProxyModel

          sipAddress: 'sip:erwan.croze@sip.linphone.org'
        }
      }
    }
  }
}
