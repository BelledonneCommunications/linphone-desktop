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
                //: "Encryption  :"
                text: qsTr("call_stats_media_encryption_title")
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
                    //: Media encryption : %1
                    text: qsTr("call_stats_media_encryption").arg(mainItem.call.core.encryptionString)
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Math.round(12 * DefaultStyle.dp)
                        weight: Math.round(500 * DefaultStyle.dp)
					}
				}
				ColumnLayout {
					visible: mainItem.call && mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
					Text {
                        //: "Algorithme de chiffrement : %1"
                        text: qsTr("call_stats_zrtp_cipher_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.cipherAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
                        //: "Algorithme d'accord de clé : %1"
                        text: qsTr("call_stats_zrtp_key_agreement_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.keyAgreementAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
                        //: "Algorithme de hachage : %1"
                        text: qsTr("call_stats_zrtp_hash_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.hashAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
                        //: "Algorithme d'authentification : %1"
                        text: qsTr("call_stats_zrtp_auth_tag_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.authenticationAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(500 * DefaultStyle.dp)
						}
					}
					Text {
                        //: "Algorithme SAS : %1"
                        text: qsTr("call_stats_zrtp_sas_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.sasAlgo)
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
        //: "Validation chiffrement"
        text: qsTr("call_zrtp_validation_button_label")
		onClicked: mainItem.encryptionValidationRequested()
        Layout.bottomMargin: Math.round(13 * DefaultStyle.dp)
        Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		style: ButtonStyle.main
	}
}
