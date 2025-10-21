import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
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
            Layout.leftMargin: Utils.getSizeWithScreenRatio(79)
			icon.source: AppIcons.leftArrow
			style: ButtonStyle.noBackground
			onClicked: {
				console.debug("[LoginLayout] User: return")
				mainItem.goBack()
			}
			//: Return
			Accessible.name: qsTr("return_accessible_name")
		},
		RowLayout {
            spacing: Utils.getSizeWithScreenRatio(15)
            Layout.leftMargin: Utils.getSizeWithScreenRatio(21)
			EffectImage {
				fillMode: Image.PreserveAspectFit
				imageSource: AppIcons.profile
				colorizationColor: DefaultStyle.main2_600
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(34)
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(34)
			}
			Text {
                //: Connexion
                text: qsTr("assistant_account_login")
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
            spacing: Utils.getSizeWithScreenRatio(20)
            Layout.rightMargin: Math.max(Utils.getSizeWithScreenRatio(10), Utils.getSizeWithScreenRatio(51 - ((51/(DefaultStyle.defaultWidth - mainWindow.minimumWidth))*(DefaultStyle.defaultWidth-mainWindow.width))))

			Text {
                Layout.rightMargin: Utils.getSizeWithScreenRatio(15)
                //: "Pas encore de compte ?"
                text: qsTr("assistant_no_account_yet")
                font.pixelSize: Typography.p1.pixelSize
                font.weight: Typography.p1.weight
			}
			BigButton {
				Layout.alignment: Qt.AlignRight
				style: ButtonStyle.main
                //: "S'inscrire"
                text: qsTr("assistant_account_register")
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
            anchors.leftMargin: Utils.getSizeWithScreenRatio(127)
			anchors.bottom: parent.bottom
			ColumnLayout {
				id: content
				spacing: 0
				LoginForm {
					id: loginForm
				}
				BigButton {
					Layout.preferredWidth: loginForm.width
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(47)
                    Layout.topMargin: Utils.getSizeWithScreenRatio(39)
					visible: !SettingsCpp.assistantHideThirdPartyAccount
                    //: "Compte SIP tiers"
                    text: qsTr("assistant_login_third_party_sip_account_title")
					style: ButtonStyle.secondary
					onClicked: {mainItem.useSIPButtonClicked()}
				}
				BigButton {
					Layout.preferredWidth: loginForm.width
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(47)
                    Layout.topMargin: Utils.getSizeWithScreenRatio(25)
                    //: "Configuration distante"
                    text: qsTr("assistant_login_remote_provisioning")
					style: ButtonStyle.secondary
					onClicked: {fetchConfigDialog.open()}
				}
			}
		},
		Image {
			z: -1
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Utils.getSizeWithScreenRatio(129)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(127)
            width: Utils.getSizeWithScreenRatio(395)
            height: Utils.getSizeWithScreenRatio(350)
			fillMode: Image.PreserveAspectFit
			source: AppIcons.loginImage
		}
	]
	Dialog{
		id: fetchConfigDialog
        height: Utils.getSizeWithScreenRatio(315)
        width: Utils.getSizeWithScreenRatio(637)
        leftPadding: Utils.getSizeWithScreenRatio(33)
        rightPadding: Utils.getSizeWithScreenRatio(33)
        topPadding: Utils.getSizeWithScreenRatio(41)
        bottomPadding: Utils.getSizeWithScreenRatio(29)
		radius: 0
        //: "Télécharger une configuration distante"
        title: qsTr('assistant_login_download_remote_config')
        //: 'Veuillez entrer le lien de configuration qui vous a été fourni :'
        text: qsTr('assistant_login_remote_provisioning_url')

        firstButton.text: qsTr("cancel")
		firstButtonAccept: false
		firstButton.style: ButtonStyle.secondary

        //: "Valider"
        secondButton.text: qsTr("validate")
		secondButtonAccept: true
		secondButton.style: ButtonStyle.main
		onAccepted:{
			UtilsCpp.useFetchConfig(configUrl.text)
		}
		content:[
			TextField{
				id: configUrl
				Layout.fillWidth: true
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(49)
                //: 'Lien de configuration distante'
                placeholderText: qsTr("settings_advanced_remote_provisioning_url")
			}
		]
	}
}
 
