
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import SettingsCpp 1.0
import UtilsCpp 1.0

AbstractSettingsLayout {
	Layout.fillWidth: true
	Layout.fillHeight: true
	id: mainItem
	property string logsUrl
	contentComponent: content

	Dialog {
		id: deleteLogs
		text: qsTr("Les traces de débogage seront supprimées. Souhaitez-vous continuer ?")
		onAccepted: SettingsCpp.cleanLogs()
	}
	
	Dialog {
		id: shareLogs
		text: qsTr("Les traces de débogage ont été téléversées. Comment souhaitez-vous partager le lien ? ")
		buttons: [
			Button {
				text: qsTr("Presse-papier")
				onClicked: {
					shareLogs.close()
					UtilsCpp.copyToClipboard(mainItem.logsUrl)
				}
			},
			Button {
				text: qsTr("E-Mail")
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
		id: content
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
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
			MediumButton {
				text: qsTr("Supprimer les traces")
				onClicked: {
					deleteLogs.open()
				}
			}
			MediumButton {
				text: qsTr("Partager les traces")
				enabled: SettingsCpp.logsEnabled || SettingsCpp.fullLogsEnabled
				onClicked: {
					UtilsCpp.getMainWindow().showLoadingPopup(qsTr("Téléversement des traces en cours ..."))
					SettingsCpp.sendLogs()
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
