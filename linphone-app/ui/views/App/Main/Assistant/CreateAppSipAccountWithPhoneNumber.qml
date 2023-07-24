import QtQuick 2.7
import QtQuick.Layouts 1.0

import Common 1.0
import Linphone 1.0

import Common.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

AssistantAbstractView {
  id: view

  property alias usernameError: username.error
  property alias phoneNumberError: phoneNumber.error

  title: qsTr('createAppSipAccountTitle').replace('%1', Qt.application.name.toUpperCase())

  mainAction: requestBlock.execute
  mainActionEnabled: phoneNumber.text.length
    && !phoneNumberError.length
    && !usernameError.length
    && !requestBlock.loading
  mainActionLabel: qsTr('confirmAction')

  Column {
    anchors.fill: parent

    Form {
      orientation: Qt.Vertical
      width: FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
      anchors.horizontalCenter: parent.horizontalCenter
      FormLine {
        FormGroup {
          label: qsTr('countryLabel')

          ComboBox {
            id: country

            currentIndex: model.defaultIndex
            model: TelephoneNumbersModel {}
            textRole: 'countryName'
			function setCode(code){
				currentIndex = Utils.findIndex(model, function (phoneModel) {
						return phoneModel.countryCode === code
					})
				assistantModel.setCountryCode(currentIndex)
			}
            onActivated: {
              assistantModel.setCountryCode(index)
            }
          }
        }
    }
	  
	  FormLine {
		  FormGroup {
			  label: qsTr('phoneNumberLabel')
			  RowLayout{
				  spacing: 5
				  TextField {
					  id: countryCode
					  Layout.fillHeight: true
					  Layout.preferredWidth: 50
					  inputMethodHints: Qt.ImhDialableCharactersOnly
					  text: "+"+assistantModel.countryCode
					  cursorPosition:1
					  onCursorPositionChanged: if(cursorPosition == 0) cursorPosition = 1
					  onTextEdited: {
						  country.setCode(text.substring(1))
						  
					  }
				  }
				  TextField {
					  id: phoneNumber
					  Layout.fillHeight: true
					  Layout.fillWidth: true
					  inputMethodHints: Qt.ImhDialableCharactersOnly
					  
					  text: assistantModel.phoneNumber
					  onTextChanged: if( assistantModel.phoneNumber != text) assistantModel.phoneNumber = text
				  }
			  }
		  }
	  }
	  
      FormLine {
        FormGroup {
          label: qsTr('usernameLabel')

          TextField {
            id: username
			placeholderText: assistantModel.computedPhoneNumber
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
      loading: assistantModel.isProcessing
    }
  }

  // ---------------------------------------------------------------------------
  // Assistant.
  // ---------------------------------------------------------------------------

  AssistantModel {
    id: assistantModel

    configFilename: 'create-app-sip-account.rc'
    
    function setCountryCode (index) {
		if(index>=0){
			var model = country.model
			assistantModel.countryCode = model.data(model.index(index, 0),"countryCode")
		}
	}

    Component.onCompleted: setCountryCode(country.model.defaultIndex)

    onPhoneNumberChanged: phoneNumberError = error
    onUsernameChanged: usernameError = error

    onCreateStatusChanged: {
      requestBlock.setText(error)
      if (error.length) {
        return
      }

      window.lockView({
        descriptionText: qsTr('quitWarning')
      })
      assistant.pushView('ActivateAppSipAccountWithPhoneNumber', {
        assistantModel: assistantModel
      })
    }
  }
}
