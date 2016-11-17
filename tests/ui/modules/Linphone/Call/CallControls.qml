import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

import Linphone 1.0
import Common 1.0

// ===================================================================

RowLayout {
  property string sipAddress

  // TODO.
  property var contact: ContactsListModel.mapSipAddressToContact(
    sipAddress
  )

  implicitHeight: contact.height
  spacing: 1

  Rectangle {
    Layout.fillWidth: true
    color: '#434343'
    implicitHeight: _contact.height

    Contact {
      id: contact

      anchors.fill: parent
      sipAddressColor: '#FFFFFF'
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

    implicitWidth: actionMenu.width
    launcher: button
    relativeTo: button
    relativeX: button.width + 1

    ActionMenu {
      id: actionMenu

      entryHeight: 22
      entryWidth: 120

      ActionMenuEntry {
        entryName: qsTr('acceptAudioCall')

        onClicked: menu.hideMenu()
      }

      ActionMenuEntry {
        entryName: qsTr('acceptVideoCall')

        onClicked: menu.hideMenu()
      }

      ActionMenuEntry {
        entryName: qsTr('hangup')

        onClicked: menu.hideMenu()
      }
    }
  }
}
