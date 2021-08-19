import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
//import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0


// =============================================================================

DialogPlus {
	id:dialog
	buttons: [
		TextButtonA {
			//: 'Exit group' : Button label
			text: qsTr('quitGroupButton')
			capitalization: Font.AllUppercase
			textButtonStyle: InfoChatRoomStyle.leaveButton
			showBorder: true
			onClicked:{
				chatRoomModel.leaveChatRoom();
				exit(0)
			}
			enabled:!chatRoomModel.hasBeenLeft
		},Item{
			Layout.fillWidth: true
		},
		TextButtonB {
			//: 'OK' : Button label
			text: qsTr('ok')
			capitalization: Font.AllUppercase
			
			onClicked: {
				if(!chatRoomModel.hasBeenLeft)
					chatRoomModel.updateParticipants(selectedParticipants.getParticipants()) // Remove/New
				exit(1)
			}
		}
	]
	flat : true
	showCloseCross: true
	//: "Group information" : Popup title.
	//~ This popup display data about the current chat room
	title: "Group information"
	
	property ChatRoomModel chatRoomModel
	buttonsAlignment: Qt.AlignBottom
	buttonsLeftMargin: InfoChatRoomStyle.mainLayout.leftMargin
	buttonsRightMargin: InfoChatRoomStyle.mainLayout.rightMargin
	
	height: InfoChatRoomStyle.height
	width: InfoChatRoomStyle.width
	
	readonly property bool adminMode : chatRoomModel.isMeAdmin && !chatRoomModel.hasBeenLeft
	
	// ---------------------------------------------------------------------------
	ColumnLayout {
		id:mainLayout
		anchors.fill: parent
		anchors.topMargin: InfoChatRoomStyle.mainLayout.topMargin
		anchors.leftMargin: InfoChatRoomStyle.mainLayout.leftMargin
		anchors.rightMargin: InfoChatRoomStyle.mainLayout.rightMargin
		spacing: InfoChatRoomStyle.mainLayout.spacing
		
		SmartSearchBar {
			id: smartSearchBar
			
			Layout.fillWidth: true
			Layout.topMargin: InfoChatRoomStyle.searchBar.topMargin
			
			showHeader:false
			
			visible: dialog.adminMode && chatRoomModel.canHandleParticipants
			
			maxMenuHeight: MainWindowStyle.searchBox.maxHeight
			//: 'Add Participants' : Placeholder in a search bar for adding participant to the chat room
			placeholderText: qsTr('addParticipantPlaceholder')
			//: 'Search participants in your contact list in order to invite them into the chat room.'
			//~ Tooltip Explanation for inviting the selected participants into chat room 
			tooltipText: qsTr('addParticipantTooltip')
			actions:[{
					icon: 'add_participant',
					secure:0,
					handler: function (entry) {
						selectedParticipants.add(entry.sipAddress)
					},
				}]
			
			onEntryClicked: {
				selectedParticipants.add(entry)
			}
		}
		
		
		ScrollableListViewField {
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.bottomMargin: 5
			
			//readOnly: toAddView.count >= conferenceManager.maxParticipants
			textFieldStyle: TextFieldStyle.normal
			
			ColumnLayout{
				anchors.fill:parent
				spacing:0
				Text{
					Layout.topMargin: InfoChatRoomStyle.results.title.topMargin
					Layout.leftMargin: InfoChatRoomStyle.results.title.leftMargin
					//: 'Participant list'
					text:qsTr('participantList')
					color: InfoChatRoomStyle.results.title.color
					font.pointSize:InfoChatRoomStyle.results.title.pointSize
					font.weight: InfoChatRoomStyle.results.title.weight
				}
				Text{
					Layout.preferredHeight: implicitHeight
					Layout.rightMargin: InfoChatRoomStyle.results.header.rightMargin
					Layout.alignment: Qt.AlignRight | Qt.AlignBottom
					//Layout.topMargin: InfoChatRoomStyle.results.topMargin
					//: 'Admin' : Admin(istrator)
					//~ one word for admin status
					text : qsTr('adminStatus')
					
					color: InfoChatRoomStyle.results.header.color
					font.pointSize: InfoChatRoomStyle.results.header.pointSize
					font.weight: InfoChatRoomStyle.results.header.weight
					visible: dialog.adminMode && participantView.count > 0
					
				}
				
				ParticipantsView {
					id: participantView
					Layout.fillHeight: true
					Layout.fillWidth: true
					//anchors.fill: parent
					
					showContactAddress:false
					showSwitch : dialog.adminMode
					showSeparator: false
					showAdminStatus:!dialog.adminMode
					isSelectable: false
					hoveredCursor:Qt.WhatsThisCursor
					
					
					actions:  dialog.adminMode ? [{
															 icon: 'remove_participant',
															 tooltipText: 'Remove this participant from the selection',
															 handler: function (entry) {
																 selectedParticipants.remove(entry)
																 //							++lastContacts.reloadCount
															 }
														 }]
													  : []
					
					genSipAddress: ''
					
					model: ParticipantProxyModel {
						id:selectedParticipants
						chatRoomModel:dialog.chatRoomModel
						onAddressAdded: smartSearchBar.addAddressToIgnore(sipAddress)
						onAddressRemoved: smartSearchBar.removeAddressToIgnore(sipAddress)
						
					}
					
					onEntryClicked: {//actions[0].handler(entry)
						if(tooltip.delay>0) {
							tooltip.oldDelay = tooltip.delay
							tooltip.delay = 0
						}
						tooltip.show(entry.sipAddress, -1);
					}
					ToolTip{
						id:tooltip	
						property int oldDelay : 0
						MouseArea{
							anchors.fill:parent
							onClicked : {
								tooltip.hide()
								tooltip.delay = tooltip.oldDelay
							}
						}					
					}
				}
			}
		}
	}
}