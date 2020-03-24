import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  description: qsTr('createAppSipAccountDescription')
  title: qsTr('createAppSipAccountTitle').replace('%1', Qt.application.name.toUpperCase())

  // ---------------------------------------------------------------------------
  // Menu.
  // ---------------------------------------------------------------------------

  Column {
    anchors.centerIn: parent
    spacing: CreateAppSipAccountStyle.buttons.spacing
    width: CreateAppSipAccountStyle.buttons.button.width

    TextButtonA {
      text: qsTr('withPhoneNumber')

      height: CreateAppSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateAppSipAccountWithPhoneNumber')
    }

    TextButtonA {
      text: qsTr('withEmailAddress')

      height: CreateAppSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateAppSipAccountWithEmail')
    }
  }
}
