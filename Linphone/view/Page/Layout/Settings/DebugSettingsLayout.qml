
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
        //: "Les traces de débogage seront supprimées. Souhaitez-vous continuer ?"
        text: qsTr("settings_debug_clean_logs_message")
		onAccepted: SettingsCpp.cleanLogs()
	}
	
	onSave: {
		SettingsCpp.save()
	}
	
	Dialog {
		id: shareLogs
        //: "Les traces de débogage ont été téléversées. Comment souhaitez-vous partager le lien ? "
        text: qsTr("settings_debug_share_logs_message")
		buttons: [
			BigButton {
                //: "Presse-papier"
                text: qsTr("settings_debug_clipboard")
				style: ButtonStyle.main
				onClicked: {
					shareLogs.close()
					UtilsCpp.copyToClipboard(mainItem.logsUrl)
				}
			},
			BigButton {
                //: "E-Mail"
                text: qsTr("settings_debug_email")
				style: ButtonStyle.main
				onClicked: {
					shareLogs.close()
                    //: "Traces %1"
                    if(!Qt.openUrlExternally("mailto:%1%2%3%4%5".arg(encodeURIComponent(SettingsCpp.logsEmail))
                        .arg('?subject=').arg(encodeURIComponent(qsTr("debug_settings_trace").arg(applicationName)))
                        .arg('&body=').arg(encodeURIComponent(mainItem.logsUrl))
					))
                    //: Une erreur est survenue.
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                    //: "Le partage par mail a échoué. Veuillez envoyer le lien %1 directement à l'adresse %2."
                    qsTr("information_popup_email_sharing_failed").arg(mainItem.logsUrl).arg(SettingsCpp.logsEmail), false)
				}
			}
		]
	}
	
	Component {
		id: logContent
		ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
			SwitchSetting {
                //: "Activer les traces de débogage"
                titleText: qsTr("settings_debug_enable_logs_title")
				propertyName: "logsEnabled"
				propertyOwner: SettingsCpp
			}
			SwitchSetting {
                //: "Activer les traces de débogage intégrales"
                titleText: qsTr("settings_debug_enable_full_logs_title")
				propertyName: "fullLogsEnabled"
				propertyOwner: SettingsCpp
			}
			RowLayout {
                spacing: Math.round(20 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignRight
				MediumButton {
					style: ButtonStyle.tertiary
                    //: "Supprimer les traces"
                    text: qsTr("settings_debug_delete_logs_title")
					onClicked: {
						deleteLogs.open()
					}
				}
				MediumButton {
					style: ButtonStyle.tertiary
                    //: "Partager les traces"
                    text: qsTr("settings_debug_share_logs_title")
					enabled: SettingsCpp.logsEnabled || SettingsCpp.fullLogsEnabled
					onClicked: {
                        //: "Téléversement des traces en cours …"
                        UtilsCpp.getMainWindow().showLoadingPopup(qsTr("settings_debug_share_logs_loading_message"))
						SettingsCpp.sendLogs()
					}
				}
			}
		}
	}
	
	Component {
	id: versionContent
		ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
			RowLayout {
				EffectImage {
					imageSource: AppIcons.appWindow
					colorizationColor: DefaultStyle.main1_500_main
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                    imageWidth: Math.round(24 * DefaultStyle.dp)
                    imageHeight: Math.round(24 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignTop
				}
				ColumnLayout {
					Text {
                        //: "Version de l'application"
                        text: qsTr("settings_debug_app_version_title")
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
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                    imageWidth: Math.round(24 * DefaultStyle.dp)
                    imageHeight: Math.round(24 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignTop
				}
				ColumnLayout {
					Text {
                        //: "Version du SDK"
                        text: qsTr("settings_debug_sdk_version_title")
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
                UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                //: "Le téléversement des traces a échoué. Vous pouvez partager les fichiers de trace directement depuis le répertoire suivant : %1"
                qsTr("settings_debug_share_logs_error").arg(SettingsCpp.logsFolder), false)
			}
		}
	}
}
