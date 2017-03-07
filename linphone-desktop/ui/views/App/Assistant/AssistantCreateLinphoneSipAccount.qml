import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  description: qsTr('createLinphoneSipAccountDescription')
  title: qsTr('createLinphoneSipAccountTitle')

  Column {
    anchors.centerIn: parent
    spacing: AssistantCreateLinphoneSipAccountStyle.buttons.spacing
    width: AssistantCreateLinphoneSipAccountStyle.buttons.button.width

    TextButtonA {
      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width
      text: qsTr('withPhoneNumber')
    }

    TextButtonA {
      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width
      text: qsTr('withEmailAddress')
    }
  }
}
