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
			text: 'QUITTER LE GROUPE'
			
			onClicked:{
				chatRoomModel.leaveChatRoom();
				exit(0)
			}
		},
		TextButtonB {
			text: 'OK'
			
			onClicked: {
				exit(1)
			}
		}
	]
	flat : true
	
	title: "Group information"
	
	property ChatRoomModel chatRoomModel
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
		
		SmartSearchBar {
			id: smartSearchBar
			
			Layout.fillWidth: true
			Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
			
			showHeader:false
			
			maxMenuHeight: MainWindowStyle.searchBox.maxHeight
			placeholderText: 'toto'
			tooltipText: 'tooltip'
			actions:[{
					icon: 'add_participant',
					secure:0,
					handler: function (entry) {
						selectedParticipants.add(entry.sipAddress)
						smartSearchBar.addAddressToIgnore(entry.sipAddress);
						++lastContacts.reloadCount
					},
				}]
			
			onEntryClicked: {
				selectedParticipants.append({$sipAddress:entry})
			}
		}
		
		Text{
			Layout.preferredHeight: 20
			Layout.rightMargin: 65
			Layout.alignment: Qt.AlignRight | Qt.AlignBottom
			Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
			text : 'Admin'
			
			color: Colors.g
			font.pointSize: Units.dp * 11
			font.weight: Font.Light
			visible: participantView.count > 0
			
		}
		ScrollableListViewField {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.bottomMargin: 5
			
			//readOnly: toAddView.count >= conferenceManager.maxParticipants
			textFieldStyle: TextFieldStyle.unbordered
			
			ParticipantsView {
				id: participantView
				anchors.fill: parent
				
				showContactAddress:false
				showSwitch : true
				showSeparator: false
				isSelectable: false
				
				
				actions: [{
						icon: 'remove_participant',
						tooltipText: 'Remove this participant from the selection',
						handler: function (entry) {
							smartSearchBar.removeAddressToIgnore(entry.sipAddress)
							selectedParticipants.remove(entry)
							++lastContacts.reloadCount
						}
					}]
				
				genSipAddress: ''
				
				model: ParticipantProxyModel {
					id:selectedParticipants
					chatRoomModel:dialog.chatRoomModel
					
				}
				
				onEntryClicked: actions[0].handler(entry)
				
			}
		}
		
	}

}