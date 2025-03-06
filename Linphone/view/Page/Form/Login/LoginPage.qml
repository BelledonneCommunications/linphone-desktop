import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

LoginLayout {
	id: mainItem
	property bool showBackButton: false
	signal goBack()
	signal useSIPButtonClicked()
	signal useRemoteConfigButtonClicked()
	signal goToRegister()

	titleContent: [
		BigButton {
			enabled: mainItem.showBackButton
			opacity: mainItem.showBackButton ? 1.0 : 0
            Layout.leftMargin: Math.round(79 * DefaultStyle.dp)
			icon.source: AppIcons.leftArrow
			style: ButtonStyle.noBackground
			onClicked: {
				console.debug("[LoginLayout] User: return")
				mainItem.goBack()
			}
		},
		RowLayout {
            spacing: Math.round(15 * DefaultStyle.dp)
            Layout.leftMargin: Math.round(21 * DefaultStyle.dp)
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
				colorizationColor: DefaultStyle.main2_600
                Layout.preferredHeight: Math.round(34 * DefaultStyle.dp)
                Layout.preferredWidth: Math.round(34 * DefaultStyle.dp)
			}
			Text {
				text: qsTr("Connexion")
				font {
                    pixelSize: Typography.h1.pixelSize
                    weight: Typography.h1.weight
				}
			}
		},
		Item {
			Layout.fillWidth: true
		},
		RowLayout {
			visible: !SettingsCpp.assistantHideCreateAccount
            spacing: Math.round(20 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(51 * DefaultStyle.dp)
			Text {
                Layout.rightMargin: Math.round(15 * DefaultStyle.dp)
				text: qsTr("Pas encore de compte ?")
                font.pixelSize: Typography.p1.pixelSize
                font.weight: Typography.p1.weight
			}
			BigButton {
				Layout.alignment: Qt.AlignRight
				style: ButtonStyle.main
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
            anchors.leftMargin: Math.round(127 * DefaultStyle.dp)
            anchors.topMargin: Math.round(70 * DefaultStyle.dp)
			anchors.bottom: parent.bottom
			ColumnLayout {
				id: content
				spacing: 0
				LoginForm {
					id: loginForm
				}
				BigButton {
					Layout.preferredWidth: loginForm.width
                    Layout.preferredHeight: Math.round(47 * DefaultStyle.dp)
                    Layout.topMargin: Math.round(39 * DefaultStyle.dp)
					visible: !SettingsCpp.assistantHideThirdPartyAccount
					text: qsTr("Compte SIP tiers")
					style: ButtonStyle.secondary
					onClicked: {mainItem.useSIPButtonClicked()}
				}
				BigButton {
					Layout.preferredWidth: loginForm.width
                    Layout.preferredHeight: Math.round(47 * DefaultStyle.dp)
                    Layout.topMargin: Math.round(25 * DefaultStyle.dp)
					text: qsTr("Configuration distante")
					style: ButtonStyle.secondary
					onClicked: {fetchConfigDialog.open()}
				}
			}
		},
		Image {
			z: -1
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Math.round(129 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(127 * DefaultStyle.dp)
            width: Math.round(395 * DefaultStyle.dp)
            height: Math.round(350 * DefaultStyle.dp)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
	Dialog{
		id: fetchConfigDialog
        height: Math.round(315 * DefaultStyle.dp)
        width: Math.round(637 * DefaultStyle.dp)
        leftPadding: Math.round(33 * DefaultStyle.dp)
        rightPadding: Math.round(33 * DefaultStyle.dp)
        topPadding: Math.round(41 * DefaultStyle.dp)
        bottomPadding: Math.round(29 * DefaultStyle.dp)
		radius: 0
		title: qsTr('Télécharger une configuration distante')
		text: qsTr('Veuillez entrer le lien de configuration qui vous a été fourni :')

		firstButton.text: 'Annuler'
		firstButtonAccept: false
		firstButton.style: ButtonStyle.secondary

		secondButton.text: 'Valider'
		secondButtonAccept: true
		secondButton.style: ButtonStyle.main
		onAccepted:{
			UtilsCpp.useFetchConfig(configUrl.text)
		}
		content:[
			TextField{
				id: configUrl
				Layout.fillWidth: true
                Layout.preferredHeight: Math.round(49 * DefaultStyle.dp)
				placeholderText: qsTr('Lien de configuration distante')
			}
		]
	}
}
 
