import Common 1.0
import Linphone 1.0
import QtQuick.Layouts 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

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
}
