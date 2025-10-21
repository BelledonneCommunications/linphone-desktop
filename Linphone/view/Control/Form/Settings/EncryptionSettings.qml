import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import SettingsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
	signal encryptionValidationRequested()
	property var call
	RoundedPane {
		Layout.fillWidth: true
        leftPadding: Utils.getSizeWithScreenRatio(16)
        rightPadding: Utils.getSizeWithScreenRatio(16)
        topPadding: Utils.getSizeWithScreenRatio(13)
        bottomPadding: Utils.getSizeWithScreenRatio(13)
		contentItem: ColumnLayout {
            spacing: Utils.getSizeWithScreenRatio(12)
			Text {
                //: "Encryption  :"
                text: qsTr("call_stats_media_encryption_title")
				Layout.alignment: Qt.AlignHCenter
				font {
                    pixelSize: Utils.getSizeWithScreenRatio(12)
                    weight: Typography.p2.weight
				}
			}
			ColumnLayout {
				Layout.alignment: Qt.AlignHCenter
                spacing: Utils.getSizeWithScreenRatio(7)
				Text {
					property bool isPostQuantum: mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp && mainItem.call.core.zrtpStats.isPostQuantum
                    //: Media encryption : %1
                    text: qsTr("call_stats_media_encryption").arg(mainItem.call.core.encryptionString)
					Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(12)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
				ColumnLayout {
					visible: mainItem.call && mainItem.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp
					Text {
                        //: "Algorithme de chiffrement : %1"
                        text: qsTr("call_stats_zrtp_cipher_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.cipherAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(500)
						}
					}
					Text {
                        //: "Algorithme d'accord de clé : %1"
                        text: qsTr("call_stats_zrtp_key_agreement_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.keyAgreementAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(500)
						}
					}
					Text {
                        //: "Algorithme de hachage : %1"
                        text: qsTr("call_stats_zrtp_hash_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.hashAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(500)
						}
					}
					Text {
                        //: "Algorithme d'authentification : %1"
                        text: qsTr("call_stats_zrtp_auth_tag_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.authenticationAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(500)
						}
					}
					Text {
                        //: "Algorithme SAS : %1"
                        text: qsTr("call_stats_zrtp_sas_algo").arg(mainItem.call && mainItem.call.core.zrtpStats.sasAlgo)
						Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(12)
                            weight: Utils.getSizeWithScreenRatio(500)
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
        Layout.bottomMargin: Utils.getSizeWithScreenRatio(13)
        Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
        Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
		style: ButtonStyle.main
	}
}
