import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone


ColumnLayout {
	id: mainItem
	spacing: 15 * DefaultStyle.dp
	signal connectionSucceed()

	TextInput {
		id: username
		label: "Username"
		mandatory: true
		enableErrorText: true

		Binding on background.border.color {
			when: errorText.opacity != 0
			value: DefaultStyle.danger_500main
		}
		Binding on textField.color {
			when: errorText.opacity != 0
			value: DefaultStyle.danger_500main
		}
	}
	TextInput {
		id: password
		label: "Password"
		mandatory: true
		hidden: true
		enableErrorText: true

		Binding on background.border.color {
			when: errorText.opacity != 0
			value: DefaultStyle.danger_500main
		}
		Binding on textField.color {
			when: errorText.opacity != 0
			value: DefaultStyle.danger_500main
		}
	}

	ErrorText {
		id: errorText
		Connections {
			target: LoginPageCpp
			onRegistrationStateChanged: {
				if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Failed) {
					errorText.text = qsTr("Le couple identifiant mot de passe ne correspont pas")
				} else if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
					mainItem.connectionSucceed()
				}
			}
		}
	}

	RowLayout {
		id: lastFormLineLayout
		Button {
			text: qsTr("Connexion")
			Layout.rightMargin: 20 * DefaultStyle.dp
			onClicked: {
				username.errorMessage = ""
				password.errorMessage = ""

				if (username.text.length == 0 || password.text.length == 0) {
					if (username.text.length == 0)
						username.errorMessage = qsTr("You must enter a username")
					if (password.text.length == 0)
						password.errorMessage = qsTr("You must enter a password")
					return
				}
				LoginPageCpp.login(username.text, password.text)
			}
		}
		Button {
			background: Item {
				visible: false
			}
			contentItem: Text {
				color: DefaultStyle.main2_500main
				text: "Forgotten password?"
				font{
					underline: true
					pixelSize: 13 * DefaultStyle.dp
					weight : 600 * DefaultStyle.dp
				}
			}
			onClicked: console.debug("[LoginForm]User: forgotten password button clicked")
		}
	
	}
}
