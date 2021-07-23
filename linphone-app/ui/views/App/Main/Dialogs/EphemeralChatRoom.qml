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
	
	property ChatRoomModel chatRoomModel
	property int timer : 0
	buttonsAlignment: Qt.AlignCenter
	
	height: ManageAccountsStyle.height
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
			iconSize:50
			Layout.preferredHeight: 50
			Layout.preferredWidth: 50
		}
		Text{
			Layout.fillWidth: true
			maximumLineCount: 2
			text: 'New messages will be deleted on both ends once it has been read by your contact. Select a timeout.'			
		}
		ComboBox{
			id:timerPicker
			textRole: "text"
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
			
		}
		
	}
	
}