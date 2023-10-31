import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal useSIPButtonClicked()
	signal goToRegister()

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			textItem.text: "Login"
			textItem.font.pointSize: DefaultStyle.title2FontPointSize
			textItem.font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			textItem.text: "No account yet ?"
			textItem.font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			Layout.alignment: Qt.AlignRight
			inversedColors: true
			text: "Register"
			onClicked: {
				console.debug("[LoginPage] User: go to register")
				mainItem.goToRegister()
			}
		}
	}

	centerContent: LoginForm {
		onUseSIPButtonClicked: mainItem.useSIPButtonClicked()
	}
}
 
