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
						return UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh, true)
					},
					handler: function (entry) {
						console.debug("Call selected: " +entry + "/"+entry.sipAddress)
						smartSearchBar.entryClicked(entry)
					},
				}]
			
			onEntryClicked: {
					console.debug("Call selected from button: " +entry + "/"+entry.sipAddress)
					mainItem.addressSelectedCallback(entry.sipAddress)
					mainItem.exit(1)
			}
		}
		 Text {
			id: description
			Layout.fillWidth: true
			
			color: SipAddressDialogStyle.list.colorModel.color
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
				optionsTogglable: false
				anchors.fill: parent
				actions:[
					{
						colorSet: SipAddressDialogStyle.select,
						visible: true,
						handler: function (entry) {
							if( entry) {
								entry.selected = true
							}
						}
					}
				]
				model: TimelineProxyModel{
					listSource: TimelineProxyModel.Copy
				}
				onEntrySelected:{
					if( entry) {
						mainItem.chatRoomSelectedCallback(entry.chatRoomModel)
						exit(1)
					}
				}
			}
		}
	}
}
