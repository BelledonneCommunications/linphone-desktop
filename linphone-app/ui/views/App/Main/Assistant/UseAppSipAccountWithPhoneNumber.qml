import Common 1.0
import Linphone 1.0

// =============================================================================

Form {
	property alias phoneNumberError: phoneNumber.error
	
	property bool mainActionEnabled: phoneNumber.text.length &&
									 !phoneNumberError.length
	
	orientation: Qt.Vertical
	FormLine{
		FormGroup {
			label: qsTr('displayNameLabel')
			
			TextField {
				text: assistantModel.displayName
				onTextChanged: if( assistantModel.displayName != text) assistantModel.displayName = text
			}
		}
	}
	
	FormLine {
		FormGroup {
			label: qsTr('countryLabel')
			
			ComboBox {
				id: country
				
				currentIndex: model.defaultIndex
				model: telephoneNumbersModel
				textRole: 'countryName'
				
				onActivated: {
					assistantModel.setCountryCode(index)
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
				text: assistantModel.phoneNumber
				onTextChanged: if( assistantModel.phoneNumber != text) assistantModel.phoneNumber = text
			}
		}
	}
}
