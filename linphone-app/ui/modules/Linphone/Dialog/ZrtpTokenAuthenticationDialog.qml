import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import Linphone.Styles 1.0

// =============================================================================
DialogPlus {
	id: mainItem
	
	property var addressSelectedCallback
	property var chatRoomSelectedCallback
	
	property var call
	property alias localSas: localSasText.text
	property alias remoteSas : remoteSasText.text
	

	buttons: [
		TextButtonA {
				//: 'Later' : Button label to do something in another time.
				text: qsTr('Later')
				onClicked: {
					if(mainItem.call) mainItem.call.verifyAuthenticationToken(false)
					mainItem.exit(0)
				}
			},
			
			TextButtonC {
				//: 'Correct' : Button label to confirm a code.
				text: qsTr('Correct')
				onClicked: {
					if(mainItem.call) mainItem.call.verifyAuthenticationToken(true)
					mainItem.exit(1)
				}
			}
	]
	
	
		
	buttonsAlignment: Qt.AlignCenter
	height: 400
	width: 350
	
	radius: 10
	onCallChanged: if(!call) exit(0)
	Component.onCompleted: if( !localSas || !remoteSas) mainItem.exit(0)


	Connections {
		target: call
		onStatusChanged: if (status === CallModel.CallStatusEnded) exit(0)
	}
		
	ColumnLayout {
		id:columnLayout
		// ---------------------------------------------------------------------------
		anchors.fill: parent
		Layout.fillWidth: true
		
		Icon{
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: 5
			icon: mainItem.call.isPQZrtp === CallModel.CallPQStateOn
						? ZrtpTokenAuthenticationDialogStyle.pqIcon
						: mainItem.call.isPQZrtp === CallModel.CallPQStateOff
							? ZrtpTokenAuthenticationDialogStyle.icon
							: ZrtpTokenAuthenticationDialogStyle.secureIcon
			iconSize: ZrtpTokenAuthenticationDialogStyle.iconSize
		}
		
		// ---------------------------------------------------------------------------
		// Main text.
		// ---------------------------------------------------------------------------
		Text {
			Layout.fillWidth: true
			
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			//: 'Communication security' : Title of popup for ZRTP confirmation.
			text: qsTr('title')
			
			color: ZrtpTokenAuthenticationDialogStyle.text.colorA.color
			wrapMode: Text.WordWrap
			
			font {
				bold: true
				pointSize: ZrtpTokenAuthenticationDialogStyle.text.titlePointSize
			}
		}
		Text {
			Layout.fillWidth: true
			
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			//: 'To raise the security level, you can check the following codes with your correspondent.' : Explanation to do a security check.
			text: qsTr('confirmSas')
			
			color: ZrtpTokenAuthenticationDialogStyle.text.colorA.color
			wrapMode: Text.WordWrap
			
			font.pointSize: ZrtpTokenAuthenticationDialogStyle.text.pointSize
		}
		
		// ---------------------------------------------------------------------------
		// Rules.
		// ---------------------------------------------------------------------------
		
		ColumnLayout {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignHCenter
			
			spacing: ZrtpTokenAuthenticationDialogStyle.text.wordsSpacing
			
			Text {
				Layout.fillWidth: true
				
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: ZrtpTokenAuthenticationDialogStyle.text.colorA.color
				font.pointSize: ZrtpTokenAuthenticationDialogStyle.text.pointSize
				text: qsTr('codeA')
			}
			
			Text {
				id: localSasText
				Layout.fillWidth: true
			
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: ZrtpTokenAuthenticationDialogStyle.text.colorB.color
				
				font {
					bold: true
					pointSize: ZrtpTokenAuthenticationDialogStyle.text.sasPointSize
				}
				
				text: mainItem.call?mainItem.call.localSas:''
			}
			
			Text {
				Layout.fillWidth: true
			
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: ZrtpTokenAuthenticationDialogStyle.text.colorA.color
				font.pointSize: ZrtpTokenAuthenticationDialogStyle.text.pointSize
				text: qsTr('codeB')
			}
			
			Text {
				id: remoteSasText
				Layout.fillWidth: true
			
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: ZrtpTokenAuthenticationDialogStyle.text.colorB.color
				
				font {
					bold: true
					pointSize: ZrtpTokenAuthenticationDialogStyle.text.sasPointSize
				}
				
				text: mainItem.call?mainItem.call.remoteSas:''
			}
		}
		
	}
}
