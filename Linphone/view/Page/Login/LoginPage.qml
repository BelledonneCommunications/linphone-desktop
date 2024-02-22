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
		spacing: 15 * DefaultStyle.dp
		Button {
			visible: mainItem.showBackButton
			Layout.preferredHeight: 27 * DefaultStyle.dp
			Layout.preferredWidth: 27 * DefaultStyle.dp
			icon.source: AppIcons.leftArrow
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
			Layout.preferredHeight: 34 * DefaultStyle.dp
			Layout.preferredWidth: 34 * DefaultStyle.dp
		}
		Text {
			text: qsTr("Connexion")
			font {
				pixelSize: 36 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
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
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			text: qsTr("S'inscrire")
			onClicked: {
				console.debug("[LoginPage] User: go to register")
				mainItem.goToRegister()
			}
		}
	}
	centerContent: ColumnLayout {
		Layout.leftMargin: 45 * DefaultStyle.dp
		RowLayout {
			
			ColumnLayout {
				LoginForm {
					onConnectionSucceed: mainItem.connectionSucceed()
				}
				Button {
					Layout.topMargin: 40 * DefaultStyle.dp
					inversedColors: true
					leftPadding: 20 * DefaultStyle.dp
					rightPadding: 20 * DefaultStyle.dp
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
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
		}
	}
}
 
