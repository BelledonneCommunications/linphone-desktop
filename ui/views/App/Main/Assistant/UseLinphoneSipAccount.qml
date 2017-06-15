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

      source: 'UseLinphoneSipAccountWith' + (
        checkBox.checked ? 'Username' : 'PhoneNumber'
      ) + '.qml'
      width: parent.width
    }

    CheckBoxText {
      id: checkBox

      text: qsTr('useUsernameToLogin')
      width: UseLinphoneSipAccountStyle.checkBox.width

      onClicked: {
        assistantModel.reset()
        requestBlock.stop('')

        if (!checked) {
          assistantModel.setCountryCode(telephoneNumbersModel.defaultIndex)
        }
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

    function setCountryCode (index) {
      var model = telephoneNumbersModel
      assistantModel.countryCode = model.data(model.index(index, 0)).countryCode
    }

    configFilename: 'use-linphone-sip-account.rc'

    countryCode: setCountryCode(telephoneNumbersModel.defaultIndex)

    onPasswordChanged: {
      if (checkBox.checked) {
        loader.item.passwordError = error
      }
    }

    onPhoneNumberChanged: {
      if (!checkBox.checked) {
        loader.item.phoneNumberError = error
      }
    }

    onLoginStatusChanged: {
      requestBlock.stop(error)
      if (!error.length) {
        window.setView('Home')
      }
    }

    onRecoverStatusChanged: {
      if (checkBox.checked) {
        requestBlock.stop('')
        return
      }

      requestBlock.stop(error)
      if (!error.length) {
        window.lockView({
          descriptionText: qsTr('quitWarning')
        })
        assistant.pushView('ActivateLinphoneSipAccountWithPhoneNumber', {
          assistantModel: assistantModel
        })
      }
    }
  }

  TelephoneNumbersModel {
    id: telephoneNumbersModel
  }
}
