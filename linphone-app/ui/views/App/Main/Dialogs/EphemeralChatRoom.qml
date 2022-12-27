import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0


// =============================================================================

DialogPlus {
	id:dialog
	buttons: [
		TextButtonA {
			//: 'cancel' : button text for cancelling operation
			text: qsTr('cancelButton')
			capitalization: Font.AllUppercase
			onClicked:{
				exit(0)
			}
		},
		TextButtonB {
			//: 'start' : button text to start ephemeral mode
			text: qsTr('startButton')
			visible: chatRoomModel.canBeEphemeral
			
			onClicked: {
				if(dialog.timer=== 0)					
					chatRoomModel.ephemeralEnabled = false
				else {
					chatRoomModel.ephemeralLifetime = dialog.timer
					chatRoomModel.ephemeralEnabled = true
				}
				exit(1)
			}
		}
	]
	flat : true
	//: "Ephemeral messages" : Popup title for ephemerals
	title: qsTr('ephemeralTitle')
	showCloseCross:false
	
	property ChatRoomModel chatRoomModel
	property int timer : 0
	buttonsAlignment: Qt.AlignCenter
	
	height: EphemeralChatRoomStyle.height
	width: EphemeralChatRoomStyle.width
	
	// ---------------------------------------------------------------------------
	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: EphemeralChatRoomStyle.mainLayout.topMargin
		anchors.leftMargin: EphemeralChatRoomStyle.mainLayout.leftMargin
		anchors.rightMargin: EphemeralChatRoomStyle.mainLayout.rightMargin
		spacing: EphemeralChatRoomStyle.mainLayout.spacing
		
		Layout.alignment: Qt.AlignCenter
		Icon{
			icon: EphemeralChatRoomStyle.timer.icon
			iconSize: EphemeralChatRoomStyle.timer.iconSize
			overwriteColor: EphemeralChatRoomStyle.timer.timerColor.color
			Layout.preferredHeight: EphemeralChatRoomStyle.timer.preferredHeight
			Layout.preferredWidth: EphemeralChatRoomStyle.timer.preferredWidth
			Layout.alignment: Qt.AlignCenter
		}
		Text{
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: EphemeralChatRoomStyle.descriptionText.leftMargin
			Layout.rightMargin: EphemeralChatRoomStyle.descriptionText.rightMargin
			
			maximumLineCount: 4
			wrapMode: Text.Wrap
			//: 'New messages will be deleted on both ends once it has been read by your contact. Select a timeout.' : Context Explanation for ephemerals
			text: qsTr('ephemeralText')
			//: 'Ephemeral message is only supported in conference based chat room!'
			//~ Context Warning about not being in conference based chat room.
				+(!chatRoomModel.canBeEphemeral?'\n'+qsTr('ephemeralNotInConference!'):'')
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: EphemeralChatRoomStyle.descriptionText.pointSize
			color: EphemeralChatRoomStyle.descriptionText.colorModel.color
		}
		ComboBox{
			Layout.alignment: Qt.AlignCenter
			Layout.preferredWidth: EphemeralChatRoomStyle.descriptionText.preferredWidth
			Layout.topMargin: EphemeralChatRoomStyle.descriptionText.topMargin
			Layout.bottomMargin: EphemeralChatRoomStyle.descriptionText.bottomMargin
			id:timerPicker
			textRole: "text"
			currentIndex:	if( chatRoomModel.ephemeralLifetime == 0 || !chatRoomModel.ephemeralEnabled)
								return 0;
							else if(  chatRoomModel.ephemeralLifetime <= 60 )
								return 1;
							else if(  chatRoomModel.ephemeralLifetime <= 3600 )
								return 2;
							else if(  chatRoomModel.ephemeralLifetime <= 86400 )
								return 3;
							else if(  chatRoomModel.ephemeralLifetime <= 259200 )
								return 4;
							else if(  chatRoomModel.ephemeralLifetime <= 604800 )
								return 5;
							else
								return 5;
			model:[
				//: 'Disabled'
				{text:qsTr('disabled'), value:0},
				//: '%1 minute'
				{ text:qsTr('nMinute', '', 1).arg(1), value:60},
				//: '%1 hour'
				{ text:qsTr('nHour', '', 1).arg(1), value:3600},
				//: '%1 day'
				{ text:qsTr('nDay', '', 1).arg(1), value:86400},
				{ text:qsTr('nDay', '', 3).arg(3), value:259200},
				//: '%1 week'
				{ text:qsTr('nWeek', '', 1).arg(1), value:604800}
			]
			
			onActivated: dialog.timer = model[index].value
			visible: chatRoomModel.canBeEphemeral
		}
	}
}