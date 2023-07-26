import Common 1.0

// =============================================================================

Form {
	property alias passwordError: password.error
	property alias usernameError: username.error
	
	property bool mainActionEnabled: password.text &&
									 username.length &&
									 !passwordError.length &&
									 !usernameError.length
	
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
			label: qsTr('usernameLabel')
			
			TextField {
				id: username
				text: assistantModel.username
				onTextChanged: if( assistantModel.username != text) assistantModel.username = text
			}
		}
	}
	
	FormLine {
		FormGroup {
			label: qsTr('passwordLabel')
			
			PasswordField {
				id: password
				
				onTextChanged: assistantModel.password = text
			}
		}
	}
}
