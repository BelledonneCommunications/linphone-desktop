import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import SettingsCpp

LoginLayout {
	id: mainItem
	property bool showBackButton: false
	signal goBack()
	signal useSIPButtonClicked()
	signal useRemoteConfigButtonClicked()
	signal goToRegister()
	signal connectionSucceed()

	titleContent: [
		Button {
			enabled: mainItem.showBackButton
			opacity: mainItem.showBackButton ? 1.0 : 0
			Layout.preferredHeight: 27 * DefaultStyle.dp
			Layout.preferredWidth: 27 * DefaultStyle.dp
			Layout.leftMargin: 79 * DefaultStyle.dp
			icon.source: AppIcons.leftArrow
			icon.width: width
			icon.height: height
			background: Rectangle {
				color: "transparent"
			}
			onClicked: {
				console.debug("[LoginLayout] User: return")
				mainItem.goBack()
			}
		},
		RowLayout {
			spacing: 15 * DefaultStyle.dp
			Layout.leftMargin: 21 * DefaultStyle.dp
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
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			visible: !SettingsCpp.assistantHideCreateAccount
			spacing: 20 * DefaultStyle.dp
			Layout.rightMargin: 51 * DefaultStyle.dp
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
	]
	centerContent: [
		Flickable {
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.leftMargin: 127 * DefaultStyle.dp
			anchors.topMargin: 70 * DefaultStyle.dp
			anchors.bottom: parent.bottom
			width: contentWidth
			contentWidth: content.implicitWidth
			contentHeight: content.implicitHeight
			clip: true
			flickableDirection: Flickable.VerticalFlick
			ColumnLayout {
				id: content
				spacing: 0
				LoginForm {
					id: loginForm
					onConnectionSucceed: mainItem.connectionSucceed()
				}
				Button {
					inversedColors: true
					Layout.preferredWidth: loginForm.width
					Layout.preferredHeight: 47 * DefaultStyle.dp
					Layout.topMargin: 39 * DefaultStyle.dp
					visible: !SettingsCpp.assistantHideThirdPartyAccount
					text: qsTr("Compte SIP tiers")
					onClicked: {mainItem.useSIPButtonClicked()}
				}
				Button {
					inversedColors: true
					Layout.preferredWidth: loginForm.width
					Layout.preferredHeight: 47 * DefaultStyle.dp
					Layout.topMargin: 25 * DefaultStyle.dp
					text: qsTr("Configuration distante")
					onClicked: {fetchConfigDialog.open()}
				}
			}
		},
		Image {
			z: -1
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.topMargin: 129 * DefaultStyle.dp
			anchors.rightMargin: 127 * DefaultStyle.dp
			width: 395 * DefaultStyle.dp
			height: 350 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
	Dialog{
		id: fetchConfigDialog
		height: 315 * DefaultStyle.dp
		width: 637 * DefaultStyle.dp
		leftPadding: 33 * DefaultStyle.dp
		rightPadding: 33 * DefaultStyle.dp
		topPadding: 41 * DefaultStyle.dp
		bottomPadding: 29 * DefaultStyle.dp
		radius: 0
		title: qsTr('Télécharger une configuration distante')
		text: qsTr('Veuillez entrer le lien de configuration qui vous a été fourni :')

		firstButton.text: 'Annuler'
		firstButtonAccept: false
		firstButton.inversedColors: true

		secondButton.text: 'Valider'
		secondButtonAccept: true
		onAccepted:{
			UtilsCpp.useFetchConfig(configUrl.text)
		}
		content:[
			TextField{
				id: configUrl
				Layout.fillWidth: true
				Layout.preferredHeight: 49 * DefaultStyle.dp
				placeholderText: qsTr('Lien de configuration distante')
			}
		]
	}
}
 
