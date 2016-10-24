import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.0

import Common 1.0
import Linphone 1.0

Window {
  id: window

  minimumHeight: 480
  minimumWidth: 960

  Paned {
    anchors.fill: parent
    defaultChildAWidth: 250
    maximumLeftLimit: 300
    minimumLeftLimit: 50

    // Calls list.
    childA: ColumnLayout {
      anchors.fill: parent
      spacing: 0

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        color: '#FFFFFF'

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 10
          anchors.left: parent.left
          iconSize: 30
          spacing: 16

          ActionButton {
            icon: 'call'
          }

          ActionButton {
            icon: 'conference'
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: 'red'
      }
    }

    // Call / Chat.
    childB: Paned {
      anchors.fill: parent
      closingEdge: Qt.RightEdge
      defaultChildAWidth: 300
      defaultClosed: true
      minimumLeftLimit: 250
      minimumRightLimit: 350
      resizeAInPriority: true

      // Call.
      childA: StartingOutgoingCall {
        anchors.fill: parent
      }

      // Chat.
      childB: Chat {
        anchors.fill: parent
      }
    }
  }
}
