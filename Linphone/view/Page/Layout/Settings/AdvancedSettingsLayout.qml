
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
            //: System
            title: qsTr("settings_system_title"),
			subTitle: "",
			contentComponent: systemComponent
		},
		{
            //: Remote provisioning
            title: qsTr("settings_remote_provisioning_title"),
			subTitle: "",
			contentComponent: remoteProvisioningComponent,
			hideTopSeparator: true
		},
		{
            //: Security / Encryption
            title: qsTr("settings_security_title"),
			subTitle: "",
			contentComponent: securityComponent,
		},
		{
            //: Audio codecs
            title: qsTr("settings_advanced_audio_codecs_title"),
			subTitle: "",
			contentComponent: audioCodecsComponent,
		},
		{
            //: Video codecs
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
            spacing: Utils.getSizeWithScreenRatio(40)
			SwitchSetting {
				Layout.fillWidth: true
                //: Auto start %1
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
            spacing: Utils.getSizeWithScreenRatio(6)
			DecoratedTextField {
				Layout.fillWidth: true
				id: configUri
                //: Remote provisioning URL
                title: qsTr("settings_advanced_remote_provisioning_url")
				toValidate: true
			}
			SmallButton {
                Layout.topMargin: Utils.getSizeWithScreenRatio(-20)
				Layout.alignment: Qt.AlignRight
                //: Download and apply
                text: qsTr("settings_advanced_download_apply_remote_provisioning")
				style: ButtonStyle.tertiary
				onClicked: {
					var url = configUri.value()
					if (UtilsCpp.isValidURL(url))
						UtilsCpp.useFetchConfig(configUri.value())
					else
                        //: Invalid URL format
                        UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"), qsTr("settings_advanced_invalid_url_message"), false, UtilsCpp.getMainWindow())
				}
				//: "Download and apply remote provisioning"
				Accessible.name: qsTr("download_apply_remote_provisioning_accessible_name")
			}
		}
	}

	Component {
		id: securityComponent
		ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(20)
			ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(5)
				Text {
                    //: Media encryption
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
					Accessible.name: qsTr("settings_advanced_media_encryption_title")
				}
			}
			SwitchSetting {
				Layout.fillWidth: true
                //: Media encryption mandatory
                titleText: qsTr("settings_advanced_media_encryption_mandatory_title")
				propertyName: "mediaEncryptionMandatory"
				propertyOwner: SettingsCpp
			}
			SwitchSetting {
				visible: false
				Layout.fillWidth: true
                //: Create end to end encrypted meetings and group calls
                titleText: qsTr("settings_advanced_create_endtoend_encrypted_meetings_title")
				propertyName: "createEndToEndEncryptedMeetingsAndGroupCalls"
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
                spacing: Utils.getSizeWithScreenRatio(20)
				model: PayloadTypeProxy {
					filterType: PayloadTypeProxy.Audio | PayloadTypeProxy.NotDownloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Utils.getSizeWithScreenRatio(32)
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
            spacing: Utils.getSizeWithScreenRatio(20)
			ListView {
				Layout.preferredHeight: contentHeight
				Layout.fillWidth: true
                spacing: Utils.getSizeWithScreenRatio(20)
				model: PayloadTypeProxy {
					id: videoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.NotDownloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Utils.getSizeWithScreenRatio(32)
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.encoderDescription
					propertyName: "enabled"
					propertyOwnerGui: modelData
				}
			}
			ListView {
				Layout.preferredHeight: contentHeight
				Layout.fillWidth: true
                spacing: Utils.getSizeWithScreenRatio(20)
				model: PayloadTypeProxy {
					id: downloadableVideoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.Downloadable
				}
				delegate: SwitchSetting {
					width: parent.width
                    height: Utils.getSizeWithScreenRatio(32)
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
            spacing: Utils.getSizeWithScreenRatio(40)
			SwitchSetting {
                //:"Cacher les FPS"
                titleText:qsTr("settings_advanced_hide_fps_title")
				propertyName: "hideFps"
				propertyOwner: SettingsCpp
			}
		}
	}
}
