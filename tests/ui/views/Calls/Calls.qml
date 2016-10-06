import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.0

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
    childA: Rectangle {
      anchors.fill: parent
      color: 'yellow'

      Text {
        text: 'calls'
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
      childA: Rectangle {
        anchors.fill: parent
        color: 'orange'

        Text {
          text: 'hello'
        }
      }

      // Chat.
      childB: Rectangle {
        anchors.fill: parent
        color: 'green'

        Text {
          text: 'hello2'
        }
      }
    }
  }
}
