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
    color: menu.isOpen() ? '#FE5E00' : '#434343'

    Text {
      anchors.centerIn: parent
      color: '#FFFFFF'
      text: '...'
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true

      onClicked: {
        menu.showMenu()
      }
    }
  }

  DropDownMenu {
    id: menu

    launcher: button
    relativeTo: button
    relativeX: button.width + 1
    implicitWidth: actionMenu.width

    ActionMenu {
      id: actionMenu

      entryHeight: 22
      entryWidth: 120
      entries: [
        qsTr('acceptAudioCall'),
        qsTr('acceptVideoCall'),
        qsTr('hangup')
      ]

      onClicked: console.log('entry', entry)
    }
  }
}
