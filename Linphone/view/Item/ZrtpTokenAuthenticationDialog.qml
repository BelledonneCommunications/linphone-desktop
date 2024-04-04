import QtQuick
import QtQuick.Layouts as Layout
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0

// =============================================================================
Dialog {
	id: mainItem
	
	property var call
		
	width: 436 * DefaultStyle.dp
	height: 549 * DefaultStyle.dp

	rightPadding: 15 * DefaultStyle.dp
	leftPadding: 15 * DefaultStyle.dp
	topPadding: 40 * DefaultStyle.dp
	bottomPadding: 40 * DefaultStyle.dp

	onCallChanged: if(!call) close()

	Connections {
		enabled: call != undefined && call != null
		target: call && call.core
		onStatusChanged: if (status === CallModel.CallStatusEnded) close()
	}

	buttons: Layout.ColumnLayout {
		spacing: 15 * DefaultStyle.dp
		Button {
			Layout.Layout.alignment: Qt.AlignHCenter
			background: Item{}
			contentItem: Text {
				text: qsTr("Skip")
				font {
					pixelSize: 13 * DefaultStyle.dp
					weight: 600 * DefaultStyle.dp
					underline: true
				}
			}
			onClicked: {
				if(mainItem.call) mainItem.call.core.lVerifyAuthenticationToken(false)
				mainItem.close()
			}
		}
		Button {
			text: qsTr("Letters doesn't match")
			color: DefaultStyle.danger_500main
			inversedColors: true
			Layout.Layout.alignment: Qt.AlignHCenter
			width: 330 * DefaultStyle.dp
			onClicked: {
				if(mainItem.call) mainItem.call.core.lVerifyAuthenticationToken(false)
				mainItem.close()
			}
		}
	}
		
	content: Layout.ColumnLayout {
		spacing: 32 * DefaultStyle.dp
		Layout.Layout.alignment: Qt.AlignHCenter
		Layout.ColumnLayout {
			spacing: 10 * DefaultStyle.dp
			Text {
				Layout.Layout.preferredWidth: 330 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter

				text: qsTr("Vérifier l'appareil")
				horizontalAlignment: Text.AlignLeft
				font {
					pixelSize: 16 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			}

			Text {
				Layout.Layout.preferredWidth: 330 * DefaultStyle.dp
				Layout.Layout.alignment: Qt.AlignHCenter
				
				horizontalAlignment: Text.AlignLeft
				//: 'To raise the security level, you can check the following codes with your correspondent.' : Explanation to do a security check.
				text: qsTr("Dites %1 et cliquez sur les lettres votre interlocuteur vous dit :".arg(mainItem.call && mainItem.call.core.localSas || ""))
				
				wrapMode: Text.WordWrap
				font.pixelSize: 14 * DefaultStyle.dp
			}
		}

		Layout.GridLayout {
			id: securityGridView
			// Layout.Layout.fillWidth: true
			Layout.Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
			rows: 2
			columns: 2
			rowSpacing: 32 * DefaultStyle.dp
			columnSpacing: 32 * DefaultStyle.dp
			property var correctIndex
			property var modelList
			Connections {
				enabled: mainItem.call
				target: mainItem.call ? mainItem.call.core : null
				// this connection is needed to get the remoteSas when available
				// due to the asynchronous connection between core and ui
				onRemoteSasChanged: {
					securityGridView.correctIndex = UtilsCpp.getRandomIndex(4)
					securityGridView.modelList = UtilsCpp.generateSecurityLettersArray(4, securityGridView.correctIndex, mainItem.call.core.remoteSas)
				}
			}
			Repeater {
				model: securityGridView.modelList
				Item {
					// implicitWidth: 70 * DefaultStyle.dp
					// implicitHeight: 70 * DefaultStyle.dp
					width: 70 * DefaultStyle.dp
					height: 70 * DefaultStyle.dp
					Rectangle {
						id: code
						anchors.fill: parent
						color: DefaultStyle.grey_0
						radius: 71 * DefaultStyle.dp
						Text {
							anchors.fill: parent
							verticalAlignment: Text.AlignVCenter
							horizontalAlignment: Text.AlignHCenter
							text: modelData
							font {
								pixelSize: 32 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
						MouseArea {
							anchors.fill: parent
							onClicked: {
								console.log("correct", index == securityGridView.correctIndex, index)
								if (index == securityGridView.correctIndex) {
									if(mainItem.call) mainItem.call.core.lVerifyAuthenticationToken(true)
								} else {
									if(mainItem.call) mainItem.call.core.lVerifyAuthenticationToken(false)
									mainItem.close()
								}
							}
						}
					}
					MultiEffect {
						source: code
						anchors.fill: code
						shadowEnabled: true
						shadowOpacity: 0.1
						shadowBlur: 1.0
					}
				}
			}
		}
	}
}
