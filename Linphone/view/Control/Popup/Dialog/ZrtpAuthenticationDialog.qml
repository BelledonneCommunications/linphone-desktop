import QtQuick
import QtQuick.Layouts as Layout
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================
Dialog {
	id: mainItem
    width: Utils.getSizeWithScreenRatio(436)
    rightPadding: Utils.getSizeWithScreenRatio(0)
    leftPadding: Utils.getSizeWithScreenRatio(0)
    topPadding: Utils.getSizeWithScreenRatio(85 + 24)
    bottomPadding: Utils.getSizeWithScreenRatio(24)
	modal: true
	closePolicy: Popup.NoAutoClose

	property var call
	onCallChanged: if(!call) close()
	property bool isTokenVerified: call && call.core.tokenVerified || false
	property bool isCaseMismatch: call && call.core.isMismatch || false
	property bool securityError: false
	// property bool firstTry: true

	background: Item {
		anchors.fill: parent
		Rectangle {
			id: backgroundItem
			anchors.fill: parent
			width: mainItem.width
			height: mainItem.implicitHeight
			color: mainItem.securityError
				? DefaultStyle.danger_500_main
				: mainItem.isCaseMismatch
					? DefaultStyle.warning_600
					: DefaultStyle.info_500_main
			radius: mainItem.radius
			Layout.ColumnLayout {
				anchors.top: parent.top
                anchors.topMargin: Utils.getSizeWithScreenRatio(18)
				anchors.horizontalCenter: parent.horizontalCenter
				Item {
                    // spacing: Utils.getSizeWithScreenRatio(14)
					Layout.Layout.preferredWidth: childrenRect.width
					Layout.Layout.preferredHeight: childrenRect.height
					Layout.Layout.fillWidth: true
					Image {
						id: trustShield
						anchors.centerIn: parent
						source: AppIcons.trustedWhite
                        sourceSize.width: Utils.getSizeWithScreenRatio(24)
                        sourceSize.height: Utils.getSizeWithScreenRatio(24)
                        width: Utils.getSizeWithScreenRatio(24)
                        height: Utils.getSizeWithScreenRatio(24)
					}
					EffectImage {
						anchors.left: trustShield.right
                        anchors.leftMargin: Utils.getSizeWithScreenRatio(14)
						visible: mainItem.securityError
						imageSource: AppIcons.shieldWarning
						colorizationColor: DefaultStyle.main2_700
                        width: Utils.getSizeWithScreenRatio(24)
                        height: Utils.getSizeWithScreenRatio(24)
					}
				}
				Text {
                    //: Vérification de sécurité
                    text: qsTr("call_dialog_zrtp_validate_trust_title")
					color: DefaultStyle.grey_0
					Layout.Layout.alignment: Qt.AlignHCenter
					font {
                        pixelSize: Typography.p2l.pixelSize
                        weight: Typography.p2l.weight
					}
				}
				Item{Layout.Layout.fillHeight: true}
			}
			SmallButton {
				visible: !mainItem.securityError
				anchors.top: parent.top
				anchors.right: parent.right
                anchors.topMargin: Utils.getSizeWithScreenRatio(10)
                anchors.rightMargin: Utils.getSizeWithScreenRatio(17)
				style: ButtonStyle.noBackground
                //: "Passer"
                text: qsTr("call_zrtp_sas_validation_skip")
				textColor: DefaultStyle.grey_0
				hoveredTextColor: DefaultStyle.grey_100
				pressedTextColor: DefaultStyle.grey_200
				underline: true
				onClicked: {
					call.core.lSkipZrtpAuthentication()
					mainItem.close()
				}
			}
		}
		Rectangle {
			z: 1
			width: mainItem.width
            height: Math.round(parent.height - Utils.getSizeWithScreenRatio(85))
			x: parent.x
            y: Math.round(parent.y + Utils.getSizeWithScreenRatio(85))
			color: DefaultStyle.grey_0
			radius: mainItem.radius
		}
		MultiEffect {
			anchors.fill: backgroundItem
			source: backgroundItem
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_900
			shadowBlur: 0.1
			shadowOpacity: 0.1
		}
	}

	content: [
		Layout.ColumnLayout {
			visible: !mainItem.securityError
            spacing: Utils.getSizeWithScreenRatio(20)
			Layout.Layout.alignment: Qt.AlignHCenter
			Layout.Layout.fillWidth: true
			Layout.ColumnLayout {
                spacing: Utils.getSizeWithScreenRatio(10)
				Layout.Layout.alignment: Qt.AlignHCenter
				Text {
                    Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(343)
					Layout.Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					text: !mainItem.isTokenVerified && mainItem.isCaseMismatch
                    //: "Pour garantir le chiffrement, nous avons besoin de réauthentifier  l’appareil de votre correspondant. Echangez vos codes :"
                    ? qsTr("call_dialog_zrtp_validate_trust_warning_message")
                    //: "Pour garantir le chiffrement, nous avons besoin d’authentifier l’appareil de votre correspondant. Veuillez échanger vos codes : "
                    : qsTr("call_dialog_zrtp_validate_trust_message")
					wrapMode: Text.WordWrap
                    font.pixelSize: Utils.getSizeWithScreenRatio(14)
				}
				Layout.ColumnLayout {
					spacing: 0
					Layout.Layout.alignment: Qt.AlignHCenter
					Text {
                        //: "Votre code :"
                        text: qsTr("call_dialog_zrtp_validate_trust_local_code_label")
						horizontalAlignment: Text.AlignHCenter
						Layout.Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Utils.getSizeWithScreenRatio(14)
					}
					Text {
						text: mainItem.call && mainItem.call.core.localToken || ""
						horizontalAlignment: Text.AlignHCenter
						Layout.Layout.alignment: Qt.AlignHCenter
						font {
                            pixelSize: Typography.b1.pixelSize
                            weight: Typography.b1.weight
						}
					}
				}
			}
			Rectangle {
				color: "transparent"
				border.color: DefaultStyle.main2_200
                border.width: Utils.getSizeWithScreenRatio(1)
                radius: Utils.getSizeWithScreenRatio(15)
                Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(292)
                Layout.Layout.preferredHeight: Utils.getSizeWithScreenRatio(233)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.ColumnLayout {
					anchors.fill: parent
                    anchors.topMargin: Utils.getSizeWithScreenRatio(10)
					Text {
                        //: "Code correspondant :"
                        text: qsTr("call_dialog_zrtp_validate_trust_remote_code_label")
                        font.pixelSize: Utils.getSizeWithScreenRatio(14)
						Layout.Layout.alignment: Qt.AlignHCenter
					}
					Layout.GridLayout {
						id: securityGridView
						Layout.Layout.alignment: Qt.AlignHCenter
						rows: 2
						columns: 2
                        rowSpacing: Utils.getSizeWithScreenRatio(32)
                        columnSpacing: Utils.getSizeWithScreenRatio(32)
						property var correctIndex
						property var modelList
						Repeater {
							model: mainItem.call && mainItem.call.core.remoteTokens || ""
							Button {
                                Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(70)
                                Layout.Layout.preferredHeight: Utils.getSizeWithScreenRatio(70)
                                width: Utils.getSizeWithScreenRatio(70)
                                height: Utils.getSizeWithScreenRatio(70)
								color: DefaultStyle.grey_0
                                textSize: Utils.getSizeWithScreenRatio(32)
                                textWeight: Utils.getSizeWithScreenRatio(400)
								text: modelData
                                shadowEnabled: true
                                radius: Utils.getSizeWithScreenRatio(71)
								textColor: DefaultStyle.main2_600
								onClicked: {
									console.log("CHECK TOKEN", modelData)
									if(mainItem.call) mainItem.call.core.lCheckAuthenticationTokenSelected(modelData)
								}
							}
						}
					}
				}
			}
		},
		Layout.ColumnLayout {
			visible: mainItem.securityError
			spacing: 0

			Text {
                width: Utils.getSizeWithScreenRatio(303)
                // Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(343)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
                //: "Le code fourni ne correspond pas."
                text: qsTr("call_dialog_zrtp_validate_trust_letters_do_not_match_text")
				wrapMode: Text.WordWrap
                font.pixelSize: Utils.getSizeWithScreenRatio(14)
			}
			Text {
                width: Utils.getSizeWithScreenRatio(303)
                // Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(343)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
                //: "La confidentialité de votre appel peut être compromise !"
                text: qsTr("call_dialog_zrtp_security_alert_message")
				wrapMode: Text.WordWrap
                font.pixelSize: Utils.getSizeWithScreenRatio(14)
			}
		}
	]

	buttons: Layout.ColumnLayout {
		Layout.Layout.alignment: Qt.AlignHCenter
		MediumButton {
			Layout.Layout.alignment: Qt.AlignHCenter
            Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(247)
            //: "Aucune correspondance"
            text: qsTr("call_dialog_zrtp_validate_trust_letters_do_not_match")
			color: DefaultStyle.grey_0
			borderColor: DefaultStyle.danger_500_main
			textColor: DefaultStyle.danger_500_main
			visible: !mainItem.securityError
			onClicked: {
				if(mainItem.call) mainItem.call.core.lCheckAuthenticationTokenSelected(" ")
			}
		}
		MediumButton {
            Layout.Layout.preferredWidth: Utils.getSizeWithScreenRatio(247)
			Layout.Layout.alignment: Qt.AlignHCenter
			visible: mainItem.securityError
			style: ButtonStyle.phoneRed
			onClicked: mainItem.call.core.lTerminate()
            spacing: Utils.getSizeWithScreenRatio(15)
            //: "Raccrocher"
            text: qsTr("call_action_hang_up")
		}
	}
}
