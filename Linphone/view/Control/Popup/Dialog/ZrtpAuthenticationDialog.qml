import QtQuick
import QtQuick.Layouts as Layout
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

// =============================================================================
Dialog {
	id: mainItem
    width: Math.round(436 * DefaultStyle.dp)
    rightPadding: Math.round(0 * DefaultStyle.dp)
    leftPadding: Math.round(0 * DefaultStyle.dp)
    topPadding: Math.round(85 * DefaultStyle.dp) + Math.round(24 * DefaultStyle.dp)
    bottomPadding: Math.round(24 * DefaultStyle.dp)
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
				? DefaultStyle.danger_500main
				: mainItem.isCaseMismatch
					? DefaultStyle.warning_600
					: DefaultStyle.info_500_main
			radius: mainItem.radius
			Layout.ColumnLayout {
				anchors.top: parent.top
                anchors.topMargin: Math.round(18 * DefaultStyle.dp)
				anchors.horizontalCenter: parent.horizontalCenter
				Item {
                    // spacing: Math.round(14 * DefaultStyle.dp)
					Layout.Layout.preferredWidth: childrenRect.width
					Layout.Layout.preferredHeight: childrenRect.height
					Layout.Layout.fillWidth: true
					Image {
						id: trustShield
						anchors.centerIn: parent
						source: AppIcons.trustedWhite
                        sourceSize.width: Math.round(24 * DefaultStyle.dp)
                        sourceSize.height: Math.round(24 * DefaultStyle.dp)
                        width: Math.round(24 * DefaultStyle.dp)
                        height: Math.round(24 * DefaultStyle.dp)
					}
					EffectImage {
						anchors.left: trustShield.right
                        anchors.leftMargin: Math.round(14 * DefaultStyle.dp)
						visible: mainItem.securityError
						imageSource: AppIcons.shieldWarning
						colorizationColor: DefaultStyle.main2_700
                        width: Math.round(24 * DefaultStyle.dp)
                        height: Math.round(24 * DefaultStyle.dp)
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
                anchors.topMargin: Math.round(10 * DefaultStyle.dp)
                anchors.rightMargin: Math.round(17 * DefaultStyle.dp)
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
            height: parent.height - Math.round(85 * DefaultStyle.dp)
			x: parent.x
            y: parent.y + Math.round(85 * DefaultStyle.dp)
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
            spacing: Math.round(20 * DefaultStyle.dp)
			Layout.Layout.alignment: Qt.AlignHCenter
			Layout.Layout.fillWidth: true
			Layout.ColumnLayout {
                spacing: Math.round(10 * DefaultStyle.dp)
				Layout.Layout.alignment: Qt.AlignHCenter
				Text {
                    Layout.Layout.preferredWidth: Math.round(343 * DefaultStyle.dp)
					Layout.Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					text: !mainItem.isTokenVerified && mainItem.isCaseMismatch
                    //: "Pour garantir le chiffrement, nous avons besoin de réauthentifier  l’appareil de votre correspondant. Echangez vos codes :"
                    ? qsTr("call_dialog_zrtp_validate_trust_warning_message")
                    //: "Pour garantir le chiffrement, nous avons besoin d’authentifier l’appareil de votre correspondant. Veuillez échanger vos codes : "
                    : qsTr("call_dialog_zrtp_validate_trust_message")
					wrapMode: Text.WordWrap
                    font.pixelSize: Math.round(14 * DefaultStyle.dp)
				}
				Layout.ColumnLayout {
					spacing: 0
					Layout.Layout.alignment: Qt.AlignHCenter
					Text {
                        //: "Votre code :"
                        text: qsTr("call_dialog_zrtp_validate_trust_local_code_label")
						horizontalAlignment: Text.AlignHCenter
						Layout.Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Math.round(14 * DefaultStyle.dp)
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
                border.width: Math.max(1, Math.round(1 * DefaultStyle.dp))
                radius: Math.round(15 * DefaultStyle.dp)
                Layout.Layout.preferredWidth: Math.round(292 * DefaultStyle.dp)
                Layout.Layout.preferredHeight: Math.round(233 * DefaultStyle.dp)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.ColumnLayout {
					anchors.fill: parent
                    anchors.topMargin: Math.round(10 * DefaultStyle.dp)
					Text {
                        //: "Code correspondant :"
                        text: qsTr("call_dialog_zrtp_validate_trust_remote_code_label")
                        font.pixelSize: Math.round(14 * DefaultStyle.dp)
						Layout.Layout.alignment: Qt.AlignHCenter
					}
					Layout.GridLayout {
						id: securityGridView
						Layout.Layout.alignment: Qt.AlignHCenter
						rows: 2
						columns: 2
                        rowSpacing: Math.round(32 * DefaultStyle.dp)
                        columnSpacing: Math.round(32 * DefaultStyle.dp)
						property var correctIndex
						property var modelList
						Repeater {
							model: mainItem.call && mainItem.call.core.remoteTokens || ""
							Button {
                                Layout.Layout.preferredWidth: Math.round(70 * DefaultStyle.dp)
                                Layout.Layout.preferredHeight: Math.round(70 * DefaultStyle.dp)
                                width: Math.round(70 * DefaultStyle.dp)
                                height: Math.round(70 * DefaultStyle.dp)
								color: DefaultStyle.grey_0
                                textSize: Math.round(32 * DefaultStyle.dp)
                                textWeight: Math.round(400 * DefaultStyle.dp)
								text: modelData
                                shadowEnabled: true
                                radius: Math.round(71 * DefaultStyle.dp)
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
                width: Math.round(303 * DefaultStyle.dp)
                // Layout.Layout.preferredWidth: Math.round(343 * DefaultStyle.dp)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
                //: "Le code fourni ne correspond pas."
                text: qsTr("call_dialog_zrtp_validate_trust_letters_do_not_match_text")
				wrapMode: Text.WordWrap
                font.pixelSize: Math.round(14 * DefaultStyle.dp)
			}
			Text {
                width: Math.round(303 * DefaultStyle.dp)
                // Layout.Layout.preferredWidth: Math.round(343 * DefaultStyle.dp)
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
                //: "La confidentialité de votre appel peut être compromise !"
                text: qsTr("call_dialog_zrtp_security_alert_message")
				wrapMode: Text.WordWrap
                font.pixelSize: Math.round(14 * DefaultStyle.dp)
			}
		}
	]

	buttons: Layout.ColumnLayout {
		Layout.Layout.alignment: Qt.AlignHCenter
		MediumButton {
			Layout.Layout.alignment: Qt.AlignHCenter
            Layout.Layout.preferredWidth: Math.round(247 * DefaultStyle.dp)
            //: "Aucune correspondance"
            text: qsTr("call_dialog_zrtp_validate_trust_letters_do_not_match")
			color: DefaultStyle.grey_0
			borderColor: DefaultStyle.danger_500main
			textColor: DefaultStyle.danger_500main
			visible: !mainItem.securityError
			onClicked: {
				if(mainItem.call) mainItem.call.core.lCheckAuthenticationTokenSelected(" ")
			}
		}
		MediumButton {
            Layout.Layout.preferredWidth: Math.round(247 * DefaultStyle.dp)
			Layout.Layout.alignment: Qt.AlignHCenter
			visible: mainItem.securityError
			style: ButtonStyle.phoneRed
			onClicked: mainItem.call.core.lTerminate()
            spacing: Math.round(15 * DefaultStyle.dp)
            //: "Raccrocher"
            text: qsTr("call_action_hang_up")
		}
	}
}
