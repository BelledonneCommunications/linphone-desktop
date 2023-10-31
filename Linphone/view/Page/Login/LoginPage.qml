import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	signal useSIPButtonClicked()
	signal goToRegister()
	signal connectionSucceed()

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			text: "Login"
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			text: "No account yet ?"
			font.pointSize: DefaultStyle.defaultTextSize
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
	centerContent: ColumnLayout {
		Layout.alignment: Qt.AlignBottom

		RowLayout {
			
			ColumnLayout {
				LoginForm {
					onConnectionSucceed: mainItem.connectionSucceed()
				}
				Button {
					Layout.topMargin: 40
					inversedColors: true
					text: "Use SIP Account"
					onClicked: {mainItem.useSIPButtonClicked()}
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
		Item {
			Layout.fillHeight: true
		}
	}
}
 
