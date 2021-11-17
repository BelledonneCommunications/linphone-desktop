import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0
import Linphone.Styles 1.0

// =============================================================================

DialogPlus {
	id: mainItem
	
	property var addressSelectedCallback
	property var chatRoomSelectedCallback
	
	buttons: [
		TextButtonA {
			text: qsTr('cancel')
			
			onClicked: exit(0)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	
	height: SipAddressDialogStyle.height + 30
	width: SipAddressDialogStyle.width
	
	// ---------------------------------------------------------------------------

			
	ColumnLayout {
		anchors.fill: parent
		spacing: SipAddressDialogStyle.spacing
		
		SmartSearchBar {
			id: smartSearchBar
			
			Layout.fillWidth: true
			Layout.topMargin: SipAddressDialogStyle.spacing
			visible: !timeline.isFilterVisible
			
			showHeader:false
			
			maxMenuHeight: MainWindowStyle.searchBox.maxHeight
			//: 'Search in contacts' : Placeholder for a search a contact
			placeholderText: qsTr('contactsSearchPlaceholder')
			//: 'Search an address in your contacts or use a custom one.' : tooltip
			tooltipText: qsTr('contactsSearchTooltip')
			
			actions:[{
					colorSet: SipAddressDialogStyle.select,
					secure: 0,
					visible: true,
					secureIconVisibleHandler : function(entry) {
						return UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh)
					},
					handler: function (entry) {
						mainItem.addressSelectedCallback(entry.sipAddress)
						exit(1)
					},
				}]
			
			onEntryClicked: {
					mainItem.addressSelectedCallback(sipAddress)
					exit(1)
			}
		}
		 Text {
			id: description
			Layout.fillWidth: true
			
			color: SipAddressDialogStyle.list.color
			font.pointSize: SipAddressDialogStyle.list.pointSize
			horizontalAlignment: Qt.AlignLeft
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.WordWrap
			//: 'Conversations' : header for a selection in conversation list
			text: qsTr('timelineSelectionHeader')
		}		
		
		ScrollableListViewField {
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			Timeline {
				id: timeline
				showHistoryButton: false
				updateSelectionModels: false
				anchors.fill: parent
				model: TimelineProxyModel{}
				onEntrySelected:{ 
					console.log(entry)
					if( entry ) {
						mainItem.chatRoomSelectedCallback(entry.chatRoomModel)
						exit(1)
					}
				}
			}
		}
	}
}
