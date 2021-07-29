import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
//import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Colors 1.0
import Units 1.0


// =============================================================================

DialogPlus {
	id:dialog
	buttons: [
		TextButtonA {
			text: 'CANCEL'
			
			onClicked:{
				exit(0)
			}
		},
		TextButtonB {
			text: 'START'
			
			onClicked: {
				console.log("Timer selected : " +dialog.timer)
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
	
	title: "Ephemeral messages"
	showCloseCross:false
	
	property ChatRoomModel chatRoomModel
	property int timer : 0
	buttonsAlignment: Qt.AlignCenter
	
	height: 320
	width: ManageAccountsStyle.width
	
	// ---------------------------------------------------------------------------
	ColumnLayout {
		anchors.fill: parent
		anchors.topMargin: 15
		anchors.leftMargin: 10
		anchors.rightMargin: 10
		spacing: 0
		
		Layout.alignment: Qt.AlignCenter
		Icon{
			icon:'timer'
			iconSize:40
			Layout.preferredHeight: 50
			Layout.preferredWidth: 50
			Layout.alignment: Qt.AlignCenter
		}
		Text{
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignCenter
			Layout.leftMargin: 10
			Layout.rightMargin: 10
			
			maximumLineCount: 4
			wrapMode: Text.Wrap
			text: 'New messages will be deleted on both ends once it has been read by your contact. Select a timeout.'
				+(!chatRoomModel.canBeEphemeral?'\nEphemeral message is only supported in conference based chat room!':'')
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			font.pointSize: Units.dp * 11
			color: Colors.d
		}
		ComboBox{
			Layout.alignment: Qt.AlignCenter
			Layout.preferredWidth: 150
			Layout.topMargin:10
			Layout.bottomMargin:10
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
			model:ListModel{
				ListElement{ text:'Disabled'
					value:0}
				ListElement{ text:'1 minute'
					value:60}
				ListElement{ text:'1 heure'
					value:3600}
				ListElement{ text:'1 jour'
					value:86400}
				ListElement{ text:'3 jours'
					value:259200}
				ListElement{ text:'1 semaine'
					value:604800}
			}
			
			onActivated: dialog.timer = model.get(index).value
			visible: chatRoomModel.canBeEphemeral
		}
		
	}
	
}