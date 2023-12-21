import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: mainItem
	property bool showBackButton: false
	signal goBack()
	signal useSIPButtonClicked()
	signal goToRegister()
	signal connectionSucceed()

	titleContent: RowLayout {
		Control.Button {
			Layout.preferredHeight: 40 * DefaultStyle.dp
			Layout.preferredWidth: height
			visible: mainItem.showBackButton
			icon.width: width
			icon.height: height
			icon.source: AppIcons.returnArrow
			background: Rectangle {
				color: "transparent"
			}
			onClicked: {
				console.debug("[LoginLayout] User: return")
				mainItem.goBack()
			}
		}
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			text: qsTr("Connexion")
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15 * DefaultStyle.dp
			text: qsTr("Pas encore de compte ?")
			font.pixelSize: 14 * DefaultStyle.dp
			font.weight: 400 * DefaultStyle.dp
		}
		Button {
			Layout.alignment: Qt.AlignRight
			text: qsTr("S'inscrire")
			onClicked: {
				console.debug("[LoginPage] User: go to register")
				mainItem.goToRegister()
			}
		}
	}
	centerContent: ColumnLayout {

		RowLayout {
			
			ColumnLayout {
				LoginForm {
					onConnectionSucceed: mainItem.connectionSucceed()
				}
				Button {
					Layout.topMargin: 40 * DefaultStyle.dp
					inversedColors: true
					text: qsTr("Compte SIP tiers")
					onClicked: {mainItem.useSIPButtonClicked()}
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Image {
				Layout.alignment: Qt.AlignVCenter
				Layout.rightMargin: 40 * DefaultStyle.dp
				Layout.preferredWidth: 395 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				source: AppIcons.loginImage
			}
			Item {
				Layout.fillHeight: true
			}
		}
	}
}
 
