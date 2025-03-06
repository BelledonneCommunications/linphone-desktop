import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
	signal encryptionValidationRequested()
	property var call
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Math.round(16 * DefaultStyle.dp)
        rightPadding: Math.round(16 * DefaultStyle.dp)
        topPadding: Math.round(13 * DefaultStyle.dp)
        bottomPadding: Math.round(13 * DefaultStyle.dp)
		contentItem: ColumnLayout {
            spacing: Math.round(12 * DefaultStyle.dp)
			Text {
				text: qsTr("Chiffrement :")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Math.round(12 * DefaultStyle.dp)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
				Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(7 * DefaultStyle.dp)
				Text {
					property bool isPostQuantum: mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp && mainItem.call.core.zrtpStats.isPostQuantum
					text: qsTr("Chiffrement du média : %1%2").arg(isPostQuantum ? "post Quantum " : "").arg(mainItem.call.core.encryptionString)
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				ColumnLayout {
					visible: mainItem.call && mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
					Text {
						text: qsTr("Cipher algorithm : %1").arg(mainItem.call && mainItem.call.core.zrtpStats.cipherAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
						text: qsTr("Key agreement algorithm : %1").arg(mainItem.call && mainItem.call.core.zrtpStats.keyAgreementAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
						text: qsTr("Hash algorithm : %1").arg(mainItem.call && mainItem.call.core.zrtpStats.hashAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
						text: qsTr("Authentication algorithm : %1").arg(mainItem.call && mainItem.call.core.zrtpStats.authenticationAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
						text: qsTr("SAS algorithm : %1").arg(mainItem.call && mainItem.call.core.zrtpStats.sasAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
				}
			}
		}
	}
	Item{Layout.fillHeight: true}
	Button {
		visible: mainItem.call && !mainItem.call.core.conference && mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
		Layout.fillWidth: true
		text: qsTr("Validation chiffrement")
		onClicked: mainItem.encryptionValidationRequested()
        Layout.bottomMargin: Math.round(13 * DefaultStyle.dp)
        Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		style: ButtonStyle.main
	}
}
