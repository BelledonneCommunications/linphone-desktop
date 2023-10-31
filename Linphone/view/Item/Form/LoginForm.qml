import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

ColumnLayout {
	spacing: 15
	TextInput {
		id: username
		label: "Username"
		mandatory: true
		textInputWidth: 250
	}
	TextInput {
		id: password
		label: "Password"
		mandatory: true
		hidden: true
		textInputWidth: 250
	}

	RowLayout {
		id: lastFormLineLayout
		Button {
			text: 'Log in'
			Layout.rightMargin: 20
			onClicked: {
				LoginPageCpp.login(username.inputText, password.inputText);
			}
		}
		Button {
			background: Item {
				visible: false
			}
			contentItem: Text {
				color: DefaultStyle.grayColor
				text: "Forgotten password?"
				font{
					underline: true
					pointSize: DefaultStyle.defaultTextSize
				}
			}
			onClicked: console.debug("[LoginForm]User: forgotten password button clicked")
		}
	
	}
}
