import QtQuick
import QtQuick.Layouts as Layout
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0

// =============================================================================
Dialog {
	id: mainItem
	width: 436 * DefaultStyle.dp
	rightPadding: 0 * DefaultStyle.dp
	leftPadding: 0 * DefaultStyle.dp
	topPadding: 85 * DefaultStyle.dp + 24 * DefaultStyle.dp
	bottomPadding: 24 * DefaultStyle.dp
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
				anchors.topMargin: 18 * DefaultStyle.dp
				anchors.horizontalCenter: parent.horizontalCenter
				Item {
					// spacing: 14 * DefaultStyle.dp
					Layout.Layout.preferredWidth: childrenRect.width
					Layout.Layout.preferredHeight: childrenRect.height
					Layout.Layout.fillWidth: true
					Image {
						id: trustShield
						anchors.centerIn: parent
						source: AppIcons.trustedWhite
						sourceSize.width: 24 * DefaultStyle.dp
						sourceSize.height: 24 * DefaultStyle.dp
						width: 24 * DefaultStyle.dp
						height: 24 * DefaultStyle.dp
					}
					EffectImage {
						anchors.left: trustShield.right
						anchors.leftMargin: 14 * DefaultStyle.dp
						visible: mainItem.securityError
						imageSource: AppIcons.shieldWarning
						colorizationColor: DefaultStyle.main2_700
						width: 24 * DefaultStyle.dp
						height: 24 * DefaultStyle.dp
					}
				}
				Text {
					text: qsTr("Vérification de sécurité")
					color: DefaultStyle.grey_0
					Layout.Layout.alignment: Qt.AlignHCenter
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 700 * DefaultStyle.dp
					}
				}
				Item{Layout.Layout.fillHeight: true}
			}
			Button {
				visible: !mainItem.securityError
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.topMargin: 10 * DefaultStyle.dp
				anchors.rightMargin: 17 * DefaultStyle.dp
				background: Item{}
				textSize: 13 * DefaultStyle.dp
				textWeight: 600 * DefaultStyle.dp
				text: qsTr("Passer")
				textColor: DefaultStyle.grey_0
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
			height: parent.height - 85 * DefaultStyle.dp
			x: parent.x
			y: parent.y + 85 * DefaultStyle.dp
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
			spacing: 20 * DefaultStyle.dp
			Layout.Layout.alignment: Qt.AlignHCenter
			Layout.Layout.fillWidth: true
			Layout.ColumnLayout {
				spacing: 10 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter
				Text {
					Layout.Layout.preferredWidth: 343 * DefaultStyle.dp
					Layout.Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					text: !mainItem.isTokenVerified && mainItem.isCaseMismatch
					? qsTr("Pour garantir le chiffrement, nous avons besoin de réauthentifier  l’appareil de votre correspondant. Echangez vos codes :")
					: qsTr("Pour garantir le chiffrement, nous avons besoin d’authentifier l’appareil de votre correspondant. Veuillez échanger vos codes : ")
					wrapMode: Text.WordWrap
					font.pixelSize: 14 * DefaultStyle.dp
				}
				Layout.ColumnLayout {
					spacing: 0
					Layout.Layout.alignment: Qt.AlignHCenter
					Text {
						text: qsTr("Votre code :")
						horizontalAlignment: Text.AlignHCenter
						Layout.Layout.alignment: Qt.AlignHCenter
						font.pixelSize: 14 * DefaultStyle.dp
					}
					Text {
						text: mainItem.call && mainItem.call.core.localToken || ""
						horizontalAlignment: Text.AlignHCenter
						Layout.Layout.alignment: Qt.AlignHCenter
						font {
							pixelSize: 18 * DefaultStyle.dp
							weight: 700 * DefaultStyle.dp
						}
					}
				}
			}
			Rectangle {
				color: "transparent"
				border.color: DefaultStyle.main2_200
				border.width: Math.max(0.5, 1 * DefaultStyle.dp)
				radius: 15 * DefaultStyle.dp
				Layout.Layout.preferredWidth: 292 * DefaultStyle.dp
				Layout.Layout.preferredHeight: 233 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.ColumnLayout {
					anchors.fill: parent
					anchors.topMargin: 10 * DefaultStyle.dp
					Text {
						text: qsTr("Code correspondant :")
						font.pixelSize: 14 * DefaultStyle.dp
						Layout.Layout.alignment: Qt.AlignHCenter
					}
					Layout.GridLayout {
						id: securityGridView
						Layout.Layout.alignment: Qt.AlignHCenter
						rows: 2
						columns: 2
						rowSpacing: 32 * DefaultStyle.dp
						columnSpacing: 32 * DefaultStyle.dp
						property var correctIndex
						property var modelList
						Repeater {
							model: mainItem.call && mainItem.call.core.remoteTokens || ""
							Button {
								Layout.Layout.preferredWidth: 70 * DefaultStyle.dp
								Layout.Layout.preferredHeight: 70 * DefaultStyle.dp
								width: 70 * DefaultStyle.dp
								height: 70 * DefaultStyle.dp
								color: DefaultStyle.grey_0
								textSize: 32 * DefaultStyle.dp
								textWeight: 400 * DefaultStyle.dp
								text: modelData
								radius: 71 * DefaultStyle.dp
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
				width: 303 * DefaultStyle.dp
				// Layout.Layout.preferredWidth: 343 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				text: qsTr("Le code fourni ne correspond pas.")
				wrapMode: Text.WordWrap
				font.pixelSize: 14 * DefaultStyle.dp
			}
			Text {
				width: 303 * DefaultStyle.dp
				// Layout.Layout.preferredWidth: 343 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter
				Layout.Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				text: qsTr("La confidentialité de votre appel peut être compromise !")
				wrapMode: Text.WordWrap
				font.pixelSize: 14 * DefaultStyle.dp
			}
		}
	]

	buttons: Layout.ColumnLayout {
		Layout.Layout.alignment: Qt.AlignHCenter
		MediumButton {
			Layout.Layout.alignment: Qt.AlignHCenter
			Layout.Layout.preferredWidth: 247 * DefaultStyle.dp
			text: qsTr("Aucune correspondance")
			color: DefaultStyle.grey_0
			borderColor: DefaultStyle.danger_500main
			textColor: DefaultStyle.danger_500main
			visible: !mainItem.securityError
			onClicked: {
				if(mainItem.call) mainItem.call.core.lCheckAuthenticationTokenSelected(" ")
			}
		}
		MediumButton {
			Layout.Layout.preferredWidth: 247 * DefaultStyle.dp
			Layout.Layout.alignment: Qt.AlignHCenter
			visible: mainItem.securityError
			style: ButtonStyle.phoneRed
			onClicked: mainItem.call.core.lTerminate()
			spacing: 15 * DefaultStyle.dp
			text: qsTr("Raccrocher")
		}
	}
}