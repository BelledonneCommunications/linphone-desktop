
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp 1.0
import Linphone
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

AbstractSettingsLayout {
	width: parent?.width
	contentModel: [
		{
			title: qsTr("Système"),
			subTitle: "",
			contentComponent: systemComponent
		},
		{
			title: qsTr("Configuration distante"),
			subTitle: "",
			contentComponent: remoteProvisioningComponent,
			hideTopSeparator: true
		},
		{
			title: qsTr("Sécurité / Chiffrement"),
			subTitle: "",
			contentComponent: securityComponent,
		},
		{
			title: qsTr("Codecs audio"),
			subTitle: "",
			contentComponent: audioCodecsComponent,
		},
		{
			title: qsTr("Codecs vidéo"),
			subTitle: "",
			contentComponent: videoCodecsComponent
		},
		{
			title: "",
			subTitle: "",
			contentComponent: hideFpsComponent
		}
	]

	// System
	/////////

	Component {
		id: systemComponent
		ColumnLayout {
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				Layout.fillWidth: true
				titleText: qsTr("Démarrer automatiquement Linphone")
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
			spacing: 6 * DefaultStyle.dp
			DecoratedTextField {
				Layout.fillWidth: true
				id: configUri
				title: qsTr("URL de configuration distante")
				toValidate: true
			}
			SmallButton {
				Layout.topMargin: -20 * DefaultStyle.dp
				Layout.alignment: Qt.AlignRight
				text: qsTr("Télécharger et appliquer")
				onClicked: {
					var url = configUri.value()
					if (UtilsCpp.isValidURL(url))
						UtilsCpp.useFetchConfig(configUri.value())
					else
						UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Format d'url invalide"), false, UtilsCpp.getMainWindow())
				}
			}
		}
	}

	Component {
		id: securityComponent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			ColumnLayout {
				spacing: 5 * DefaultStyle.dp
				Text {
					text: qsTr("Chiffrement du média")
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 700 * DefaultStyle.dp
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
				titleText: qsTr("Chiffrement du média obligatoire")
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
			spacing: 20 * DefaultStyle.dp
			Repeater {
				model: PayloadTypeProxy {
					filterType: PayloadTypeProxy.Audio | PayloadTypeProxy.NotDownloadable
				}
				SwitchSetting {
					Layout.fillWidth: true
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.clockRate + " Hz"
					propertyName: "enabled"
					propertyOwner: modelData.core
				}
			}
		}
	}

	// Video codecs
	//////////////

	Component {
		id: videoCodecsComponent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			Repeater {
				model: PayloadTypeProxy {
					id: videoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.NotDownloadable
				}
				SwitchSetting {
					Layout.fillWidth: true
					titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
					subTitleText: modelData.core.encoderDescription
					propertyName: "enabled"
					propertyOwner: modelData.core
				}
			}
			Repeater {
				model: PayloadTypeProxy {
					id: downloadableVideoPayloadTypeProxy
					filterType: PayloadTypeProxy.Video | PayloadTypeProxy.Downloadable
				}
				SwitchSetting {
					Layout.fillWidth: true
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
			spacing: 40 * DefaultStyle.dp
			SwitchSetting {
				titleText:qsTr("Cacher les FPS")
				propertyName: "hideFps"
				propertyOwner: SettingsCpp
			}
		}
	}
}
