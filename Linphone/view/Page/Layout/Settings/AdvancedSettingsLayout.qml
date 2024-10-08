
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import UtilsCpp 1.0
import Linphone
import 'qrc:/Linphone/view/Control/Tool/Helper/utils.js' as Utils

AbstractSettingsLayout {
	contentComponent: content
	Component {
		id: content
		ColumnLayout {
			width: parent.width
			spacing: 5 * DefaultStyle.dp
			RowLayout {
				Layout.topMargin: 16 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 5 * DefaultStyle.dp
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Layout.maximumWidth: 341 * DefaultStyle.dp
						Layout.minimumWidth: 341 * DefaultStyle.dp
						spacing: 5 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							text: qsTr("Configuration distante")
							font: Typography.h4
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 20 * DefaultStyle.dp
					Layout.rightMargin: 44 * DefaultStyle.dp
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
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
			Rectangle {
				Layout.fillWidth: true
				Layout.topMargin: 35 * DefaultStyle.dp
				Layout.bottomMargin: 9 * DefaultStyle.dp
				height: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
			}
			RowLayout {
				Layout.topMargin: 16 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 5 * DefaultStyle.dp
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Layout.maximumWidth: 341 * DefaultStyle.dp
						Layout.minimumWidth: 341 * DefaultStyle.dp
						spacing: 5 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							text: qsTr("Codecs Audio")
							font: Typography.h4
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 20 * DefaultStyle.dp
					Layout.rightMargin: 44 * DefaultStyle.dp
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
					Repeater {
						model: PayloadTypeProxy {
							family: PayloadTypeCore.Audio
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
			Rectangle {
				Layout.fillWidth: true
				Layout.topMargin: 35 * DefaultStyle.dp
				Layout.bottomMargin: 9 * DefaultStyle.dp
				height: 1 * DefaultStyle.dp
				color: DefaultStyle.main2_500main
			}
			RowLayout {
				Layout.topMargin: 16 * DefaultStyle.dp
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 5 * DefaultStyle.dp
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Layout.maximumWidth: 341 * DefaultStyle.dp
						Layout.minimumWidth: 341 * DefaultStyle.dp
						spacing: 5 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							text: qsTr("Codecs Vidéo")
							font: Typography.h4
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 20 * DefaultStyle.dp
					Layout.rightMargin: 44 * DefaultStyle.dp
					Layout.topMargin: 20 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
					Repeater {
						model: PayloadTypeProxy {
							family: PayloadTypeCore.Video
						}
						SwitchSetting {
							Layout.fillWidth: true
							titleText: Utils.capitalizeFirstLetter(modelData.core.mimeType)
							subTitleText: modelData.core.recvFmtp
							propertyName: "enabled"
							propertyOwner: modelData.core
						}
					}
				}
			}
		}
	}
}
