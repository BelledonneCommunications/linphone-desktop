
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
			title: qsTr("Configuration distante"),
			subTitle: "",
			contentComponent: remoteProvisioningComponent
		},
		{
			title: qsTr("Codecs Audio"),
			subTitle: "",
			contentComponent: audioCodecsComponent,
		},
		{
			title: qsTr("Codecs Vidéo"),
			subTitle: "",
			contentComponent: videoCodecsComponent
		},
		{
			title: "",
			subTitle: "",
			contentComponent: hideFpsComponent
		}
	]

	// Remote Provisioning
	//////////////////////

	Component {
		id: remoteProvisioningComponent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			DecoratedTextField {
				Layout.fillWidth: true
				id: configUri
				title: qsTr("URL de configuration distante")
				toValidate: true
			}
			SmallButton {
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

	//Audio codecs
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

	//Video codecs
	//////////////

	Component {
		id: videoCodecsComponent
		ColumnLayout {
			spacing: 20 * DefaultStyle.dp
			Repeater {
				model: PayloadTypeProxy {
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
