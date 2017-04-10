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
    spacing: AssistantCreateLinphoneSipAccountStyle.buttons.spacing
    width: AssistantCreateLinphoneSipAccountStyle.buttons.button.width

    TextButtonA {
      text: qsTr('withPhoneNumber')

      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('AssistantCreateLinphoneSipAccountWithPhoneNumber')
    }

    TextButtonA {
      text: qsTr('withEmailAddress')

      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('AssistantCreateLinphoneSipAccountWithEmail')
    }
  }
}
