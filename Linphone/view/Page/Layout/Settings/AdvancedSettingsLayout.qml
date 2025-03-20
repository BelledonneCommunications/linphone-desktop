
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp 1.0
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

AbstractSettingsLayout {
	width: parent?.width
	contentModel: [
		{
            //: "Système"
            title: qsTr("settings_system_title"),
			subTitle: "",
			contentComponent: systemComponent
		},
		{
            //: "Configuration distante"
            title: qsTr("settings_remote_provisioning_title"),
			subTitle: "",
			contentComponent: remoteProvisioningComponent,
			hideTopSeparator: true
		},
		{
            //: "Sécurité / Chiffrement"
            title: qsTr("settings_security_title"),
			subTitle: "",
			contentComponent: securityComponent,
		},
		{
            //: "Codecs audio"
            title: qsTr("settings_advanced_audio_codecs_title"),
			subTitle: "",
			contentComponent: audioCodecsComponent,
		},
		{
            //: "Codecs vidéo"
            title: qsTr("settings_advanced_video_codecs_title"),
			subTitle: "",
			contentComponent: videoCodecsComponent
		},
		{
			title: "",
			subTitle: "",
			contentComponent: hideFpsComponent
		}
	]

	onSave: {
		SettingsCpp.save()
	}
	onUndo: SettingsCpp.undo()

	// System
	/////////

	Component {
		id: systemComponent
		ColumnLayout {
            spacing: Math.round(40 * DefaultStyle.dp)
			SwitchSetting {
				Layout.fillWidth: true
                //: "Démarrer automatiquement %1"
                titleText: qsTr("settings_advanced_auto_start_title").arg(applicationName)
				propertyName: "autoStart"
				propertyOwner: SettingsCpp
			}
		}
	}

	// Remote Provisioning
	//////////////////////

	Component {
		id: remoteProvisioningComponent
		ColumnLayout {
            spacing: Math.round(6 * DefaultStyle.dp)
			DecoratedTextField {
				Layout.fillWidth: true
				id: configUri
                //: "URL de configuration distante"
                title: qsTr("settings_advanced_remote_provisioning_url")
				toValidate: true
			}
			SmallButton {
                Layout.topMargin: -Math.round(20 * DefaultStyle.dp)
				Layout.alignment: Qt.AlignRight
                //: "Télécharger et appliquer"
                text: qsTr("settings_advanced_download_apply_remote_provisioning")
				style: ButtonStyle.tertiary
				onClicked: {
					var url = configUri.value()
					if (UtilsCpp.isValidURL(url))
						UtilsCpp.useFetchConfig(configUri.value())
					else
                        //: "Format d'url invalide"
                        UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"), qsTr("settings_advanced_invalid_url_message"), false, UtilsCpp.getMainWindow())
				}
			}
		}
	}

	Component {
		id: securityComponent
		ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
			ColumnLayout {
                spacing: Math.round(5 * DefaultStyle.dp)
				Text {
                    //: "Chiffrement du média"
                    text: qsTr("settings_advanced_media_encryption_title")
					font {
                        pixelSize: Typography.p2l.pixelSize
                        weight: Typography.p2l.weight
					}
				}
				ComboSetting {
					Layout.fillWidth: true
					Layout.preferredWidth: parent.width
					entries: SettingsCpp.mediaEncryptions
					propertyName: "mediaEncryption"
					textRole: 'display_name'
					propertyOwner: SettingsCpp
				}
			}
			SwitchSetting {
				Layout.fillWidth: true
                //: "Chiffrement du média obligatoire"
                titleText: qsTr("settings_advanced_media_encryption_mandatory_title")
				propertyName: "mediaEncryptionMandatory"
				propertyOwner: SettingsCpp
			}
		}
	}

	// Audio codecs
	//////////////

	Component {
		id: audioCodecsComponent
		ColumnLayout {
			ListView {
				Layout.preferredHeight: contentHeight
				Layout.fillWidth: true
                spacing: Math.round(20 * DefaultStyle.dp)
				model: PayloadTypeProxy {
					filterType: PayloadTypeProxy.Audio | PayloadTypeProxy.NotDownloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Math.round(32 * DefaultStyle.dp)
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.clockRate + " Hz"
					propertyName: "enabled"
					propertyOwnerGui: modelData
				}
			}
		}
	}

	// Video codecs
	//////////////

	Component {
		id: videoCodecsComponent
		ColumnLayout {
            spacing: Math.round(20 * DefaultStyle.dp)
			ListView {
				Layout.preferredHeight: contentHeight
				Layout.fillWidth: true
                spacing: Math.round(20 * DefaultStyle.dp)
				model: PayloadTypeProxy {
					id: videoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.NotDownloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Math.round(32 * DefaultStyle.dp)
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.encoderDescription
					propertyName: "enabled"
					propertyOwnerGui: modelData
				}
			}
			ListView {
				Layout.preferredHeight: contentHeight
				Layout.fillWidth: true
                spacing: Math.round(20 * DefaultStyle.dp)
				model: PayloadTypeProxy {
					id: downloadableVideoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.Downloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Math.round(32 * DefaultStyle.dp)
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.encoderDescription
					onCheckedChanged: Utils.openCodecOnlineInstallerDialog(
						UtilsCpp.getMainWindow(),
						modelData.core,
						function cancelCallBack() {
							setChecked(false)
						},
						function successCallBack() {
							videoPayloadTypeProxy.reload()
							downloadableVideoPayloadTypeProxy.reload()
						},
						function errorCallBack() {
							setChecked(false)
						})
				}
			}
		}
	}

	//Hide fps
	//////////

	Component {
		id: hideFpsComponent
		ColumnLayout {
            spacing: Math.round(40 * DefaultStyle.dp)
			SwitchSetting {
                //:"Cacher les FPS"
                titleText:qsTr("settings_advanced_hide_fps_title")
				propertyName: "hideFps"
				propertyOwner: SettingsCpp
			}
		}
	}
}
