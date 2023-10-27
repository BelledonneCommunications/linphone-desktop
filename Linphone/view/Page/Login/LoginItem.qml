import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

RowLayout {
	Layout.alignment: Qt.AlignBottom
	ColumnLayout {
		FormTextInputCell {
			id: username
			label: "Username"
			mandatory: true
			textInputWidth: 250
		}
		FormTextInputCell {
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
					console.debug("[LoginItem] User: Log in")
					LoginPageCpp.login(username.inputText, password.inputText);
				}
			}
			Text {
				color: DefaultStyle.grayColor
				text: "Forgotten password?"
				font.underline: true
				font.pointSize: DefaultStyle.defaultTextSize
			}
			
		}
		Button {
			Layout.topMargin: 40
			inversedColors: true
			text: "Use SIP Account"
			onClicked: {
				console.debug("[LoginItem] User: click use Sip")
				root.useSIP()
			}
		}
	}
	Item {
		Layout.fillWidth: true
	}
	Image {
		Layout.rightMargin: 40
		Layout.preferredWidth: 300
		fillMode: Image.PreserveAspectFit
		source: AppIcons.loginImage
	}
}
