
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import SettingsCpp 1.0
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractSettingsLayout {
	Layout.fillWidth: true
	Layout.fillHeight: true
	id: mainItem
	property string logsUrl
	contentModel: [
		{
			title: "",
			subTitle: "",
			contentComponent: versionContent
		},
		{
			title: "",
			subTitle: "",
			contentComponent: logContent
		}
	]

	Dialog {
		id: deleteLogs
		text: qsTr("Les traces de débogage seront supprimées. Souhaitez-vous continuer ?")
		onAccepted: SettingsCpp.cleanLogs()
	}
	
	onSave: {
		SettingsCpp.save()
	}
	
	Dialog {
		id: shareLogs
		text: qsTr("Les traces de débogage ont été téléversées. Comment souhaitez-vous partager le lien ? ")
		buttons: [
			BigButton {
				text: qsTr("Presse-papier")
				style: ButtonStyle.main
				onClicked: {
					shareLogs.close()
					UtilsCpp.copyToClipboard(mainItem.logsUrl)
				}
			},
			BigButton {
				text: qsTr("E-Mail")
				style: ButtonStyle.main
				onClicked: {
					shareLogs.close()
					if(!Qt.openUrlExternally(
          				'mailto:' + encodeURIComponent(SettingsCpp.logsEmail) +
          				'?subject=' + encodeURIComponent(qsTr('Traces Linphone')) +
          				'&body=' + encodeURIComponent(mainItem.logsUrl)
					))
					UtilsCpp.showInformationPopup(qsTr("Une erreur est survenue."), qsTr("Le partage par mail a échoué. Veuillez envoyer le lien %1 directement à l'adresse %2.").replace("%1",mainItem.logsUrl).replace("%2",SettingsCpp.logsEmail), false)
				}
			}
		]
	}
	
	Component {
		id: logContent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			SwitchSetting {
				titleText: qsTr("Activer les traces de débogage")
				propertyName: "logsEnabled"
				propertyOwner: SettingsCpp
			}
			SwitchSetting {
				titleText: qsTr("Activer les traces de débogage intégrales")
				propertyName: "fullLogsEnabled"
				propertyOwner: SettingsCpp
			}
			RowLayout {
				spacing: 20 * DefaultStyle.dp
				Layout.alignment: Qt.AlignRight
				MediumButton {
					style: ButtonStyle.tertiary
					text: qsTr("Supprimer les traces")
					onClicked: {
						deleteLogs.open()
					}
				}
				MediumButton {
					style: ButtonStyle.tertiary
					text: qsTr("Partager les traces")
					enabled: SettingsCpp.logsEnabled || SettingsCpp.fullLogsEnabled
					onClicked: {
						UtilsCpp.getMainWindow().showLoadingPopup(qsTr("Téléversement des traces en cours ..."))
						SettingsCpp.sendLogs()
					}
				}
			}
		}
	}
	
	Component {
	id: versionContent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			RowLayout {
				EffectImage {
					imageSource: AppIcons.appWindow
					colorizationColor: DefaultStyle.main1_500_main
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					imageWidth: 24 * DefaultStyle.dp
					imageHeight: 24 * DefaultStyle.dp
					Layout.alignment: Qt.AlignTop
				}
				ColumnLayout {
					Text {
						text: qsTr("Version de l'application")
						font: Typography.p2l
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
					TextEdit {
						text: AppCpp.applicationVersion + ' ('+ AppCpp.gitBranchName + ')'
						font: Typography.p1
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
						readOnly: true
					}
				}
			}
			RowLayout {
				EffectImage {
					imageSource: AppIcons.resourcePackage
					colorizationColor: DefaultStyle.main1_500_main
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					imageWidth: 24 * DefaultStyle.dp
					imageHeight: 24 * DefaultStyle.dp
					Layout.alignment: Qt.AlignTop
				}
				ColumnLayout {
					Text {
						text: qsTr("Version du SDK")
						font: Typography.p2l
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
					}
					TextEdit {
						text: AppCpp.sdkVersion
						font: Typography.p1
						wrapMode: Text.WordWrap
						color: DefaultStyle.main2_600
						Layout.fillWidth: true
						readOnly: true
					}
				}
			}
		}
	}
	
	Connections {
		target: SettingsCpp
		function onLogsUploadTerminated(status, url) {
			UtilsCpp.getMainWindow().closeLoadingPopup()
			if (status) {
				mainItem.logsUrl = url
				shareLogs.open()
			} else {
				UtilsCpp.showInformationPopup(qsTr("Une erreur est survenue."), qsTr("Le téléversement des traces a échoué. Vous pouvez partager les fichiers de trace directement depuis le répertoire suivant :") + SettingsCpp.logsFolder, false)
			}
		}
	}
}
