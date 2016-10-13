import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

ColumnLayout  {
  spacing: 0

  // Contact bar.
  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 102
    color: '#D1D1D1'

    RowLayout {
      anchors.left: parent.left
      anchors.leftMargin: 40
      anchors.right: parent.right
      anchors.rightMargin: 40
      anchors.verticalCenter: parent.verticalCenter
      height: 80
      spacing: 50
      width: parent.width

      Avatar {
        Layout.fillHeight: true
        Layout.preferredWidth: 80
        presenceLevel: Presence.Green // TODO: Use C++.
        username: 'Cameron Andrews' // TODO: Use C++.
      }

      Column {
        Layout.fillHeight: true
        Layout.fillWidth: true

        // Contact description.
        ContactDescription {
          height: parent.height * 0.60
          sipAddress: 'cam.andrews@sip.linphone.org' // TODO: Use C++.
          username: 'Cameron Andrews' // TODO: Use C++.
          width: parent.width
        }

        // Contact actions.
        Row {
          height: parent.height * 0.40
          width: parent.width

          ActionBar {
            iconSize: 32
            width: parent.width / 2

            ActionButton {
              icon: 'cam'
              onClicked: console.log('clicked!!!')
            }

            ActionButton {
              icon: 'call'
              onClicked: console.log('clicked!!!')
            }
          }

          ActionBar {
            iconSize: 32
            layoutDirection: Qt.RightToLeft
            width: parent.width / 2

            ActionButton {
              icon: 'delete'
              onClicked: console.log('clicked!!!')
            }

            ActionButton {
              icon: 'contact'
              onClicked: window.setView('Contact')
            }
          }
        }
      }
    }
  }

  // Messages/Calls filter.
  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    color: '#C7C7C7'

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: 1

      ExclusiveButtons {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        texts: [
          qsTr('displayCallsAndMessages'),
          qsTr('displayCalls'),
          qsTr('displayMessages')
        ]
      }
    }
  }

  Borders {
    Layout.fillHeight: true
    Layout.fillWidth: true
    borderColor: '#C7C7C7'
    bottomWidth: 1
    leftWidth: 1
    topWidth: 1

    Chat {
      ScrollBar.vertical: ForceScrollBar { }
      anchors.fill: parent
    }
  }

  Borders {
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    borderColor: '#C7C7C7'
    leftWidth: 1

    DroppableTextArea {
      anchors.fill: parent
      placeholderText: qsTr('newMessagePlaceholder')
    }
  }
}
