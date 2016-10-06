import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.0

import Linphone 1.0

Window {
  minimumHeight: 480
  minimumWidth: 780

  id: window

  Paned {
    anchors.fill: parent
    maximumLeftLimit: 300
    minimumLeftLimit: 50

    childA: Rectangle {
      anchors.fill: parent
      color: 'yellow'

      Text {
        text: 'calls'
      }
    }

    childB: Paned {
      anchors.fill: parent
      closingEdge: Qt.RightEdge
      defaultClosed: true
      minimumLeftLimit: '40%'
      minimumRightLimit: 200

      childA: Rectangle {
        anchors.fill: parent
        color: 'orange'

        Text {
          text: 'hello'
        }
      }

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
