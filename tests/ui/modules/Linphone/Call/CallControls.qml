import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

import Linphone 1.0
import Common 1.0

RowLayout {
  implicitHeight: contact.height
  spacing: 1

  Rectangle {
    Layout.fillWidth: true
    color: '#434343'
    implicitHeight: contact.height

    Contact {
      id: contact

      anchors.fill: parent
      presenceLevel: Presence.Green
      sipAddress: 'math.hart@sip-linphone.org'
      sipAddressColor: '#FFFFFF'
      username: 'Mathilda Hart'
      usernameColor: '#FFFFFF'
    }
  }

  Rectangle {
    id: button

    Layout.preferredHeight: contact.height
    Layout.preferredWidth: 42
    color: '#434343'

    Text {
      anchors.centerIn: parent
      color: '#FFFFFF'
      text: '...'
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      onClicked: {
        menu.show()
      }
    }
  }

  DropDownMenu {
    drawOnRoot: true
    id: menu
    entryHeight: 22
    height: 100
    width: 120
    relativeTo: button
    Keys.onEscapePressed: hide()

    Rectangle {
      color: 'red'
      anchors.fill: parent
    }
  }
}
