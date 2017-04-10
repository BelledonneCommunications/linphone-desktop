import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: requestBlock.execute
  mainActionEnabled: {
    var item = loader.item
    return item && item.mainActionEnabled && !requestBlock.loading
  }
  mainActionLabel: qsTr('confirmAction')

  title: qsTr('useLinphoneSipAccountTitle')

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    Loader {
      id: loader

      source: 'AssistantUseLinphoneSipAccountWith' + (
        checkBox.checked ? 'Username' : 'PhoneNumber'
      ) + '.qml'
      width: parent.width
    }

    CheckBoxText {
      id: checkBox

      text: qsTr('useUsernameToLogin')
      width: AssistantUseLinphoneSipAccountStyle.checkBox.width

      onClicked: {
        assistantModel.reset()
        requestBlock.stop('')
      }
    }

    RequestBlock {
      id: requestBlock

      action: assistantModel.login
      width: parent.width
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    onPasswordChanged: {
      if (checkBox.checked) {
        loader.item.passwordError = error
      }
    }

    onUsernameChanged: {
      if (checkBox.checked) {
        loader.item.usernameError = error
      }
    }

    onLoginStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        window.setView('Home')
      }
    }
  }
}
