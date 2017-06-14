import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

AssistantAbstractView {
  id: view

  property alias usernameError: username.error
  property alias phoneNumberError: phoneNumber.error

  function setCountryCode (index) {
    var model = country.model
    assistantModel.countryCode = model.data(model.index(index, 0)).countryCode
  }

  title: qsTr('createLinphoneSipAccountTitle')

  mainAction: requestBlock.execute
  mainActionEnabled: phoneNumber.text.length
    && username.text.length
    && !phoneNumberError.length
    && !usernameError.length
    && !requestBlock.loading
  mainActionLabel: qsTr('confirmAction')

  Column {
    anchors.fill: parent

    Form {
      dealWithErrors: true
      orientation: Qt.Vertical
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('countryLabel')

          ComboBox {
            id: country

            currentIndex: model.defaultIndex
            model: TelephoneNumbersModel {}
            textRole: 'countryName'

            onActivated: {
              view.setCountryCode(index)
              var text = phoneNumber.text
              if (text.length > 0) {
                assistantModel.phoneNumber = text
              }
            }
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('phoneNumberLabel')

          TextField {
            id: phoneNumber

            inputMethodHints: Qt.ImhDialableCharactersOnly

            onTextChanged: assistantModel.phoneNumber = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('usernameLabel')

          TextField {
            id: username

            onTextChanged: assistantModel.username = text
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('displayNameLabel')

          TextField {
            onTextChanged: assistantModel.displayName = text
          }
        }
      }
    }

    RequestBlock {
      id: requestBlock

      action: assistantModel.create
      width: parent.width
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    configFilename: 'create-linphone-sip-account.rc'

    Component.onCompleted: view.setCountryCode(country.model.defaultIndex)

    onPhoneNumberChanged: phoneNumberError = error
    onUsernameChanged: usernameError = error

    onCreateStatusChanged: {
      requestBlock.stop(error)
      if (error.length) {
        return
      }

      window.lockView({
        descriptionText: qsTr('quitWarning')
      })
      assistant.pushView('ActivateLinphoneSipAccountWithPhoneNumber', {
        assistantModel: assistantModel
      })
    }
  }
}
