import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  description: qsTr('createLinphoneSipAccountDescription')
  title: qsTr('createLinphoneSipAccountTitle')

  // ---------------------------------------------------------------------------
  // Menu.
  // ---------------------------------------------------------------------------

  Column {
    anchors.centerIn: parent
    spacing: CreateLinphoneSipAccountStyle.buttons.spacing
    width: CreateLinphoneSipAccountStyle.buttons.button.width

    TextButtonA {
      text: qsTr('withPhoneNumber')

      height: CreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateLinphoneSipAccountWithPhoneNumber')
    }

    TextButtonA {
      text: qsTr('withEmailAddress')

      height: CreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateLinphoneSipAccountWithEmail')
    }
  }
}
