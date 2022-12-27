import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	id: callTransfer
	
	// ---------------------------------------------------------------------------
	
	property var call
	property bool attended: false
	
	// ---------------------------------------------------------------------------
	
	buttons: [
		TextButtonA {
			text: qsTr('cancel')
			
			onClicked: exit(0)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	descriptionText: qsTr('callTransferDescription')
	
	height: CallTransferStyle.height + 30
	width: CallTransferStyle.width
	
	onCallChanged: !call && exit(0)
	
	// ---------------------------------------------------------------------------
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Contact.
		// -------------------------------------------------------------------------
		
		Contact {
			Layout.fillWidth: true
			
			entry: SipAddressesModel.getSipAddressObserver(call ? call.fullPeerAddress : '', call ? call.fullLocalAddress : '')
			Component.onDestruction: entry=null// Need to set it to null because of not calling destructor if not.
		}
		
		// -------------------------------------------------------------------------
		// Address selector.
		// -------------------------------------------------------------------------
		
		Item {
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			ColumnLayout {
				anchors.fill: parent
				spacing: CallTransferStyle.spacing
				
				TextField {
					id: filter
					
					Layout.fillWidth: true
					
					icon: text == '' ? 'search_custom' : 'close_custom'
					overwriteColor: CallTransferStyle.searchField.colorModel.color
					
					onTextChanged: sipAddressesModel.setFilter(text)
				}
				
				ScrollableListViewField {
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					SipAddressesView {
						anchors.fill: parent
						
						function transfer(sipAddress){
							if (attended) {
								var call = CallsListModel.launchAudioCall(sipAddress, callTransfer.call.peerAddress)
							} else {
								callTransfer.call.transferTo(sipAddress)
							}
							exit(1)
						}
						actions: [{
								colorSet: CallTransferStyle.transfer,
								secure: 0,
								visible: true,
								handlerSipAddress: function(sipAddress){
									transfer(sipAddress)
								},
								handler: function (entry) { 
									transfer(entry.sipAddress)
								}
								
							}]
						
						genSipAddress: filter.text
						
						model: SearchSipAddressesModel {
							id: sipAddressesModel
						}
						
						onEntryClicked: actions[0].handlerSipAddress(entry.sipAddress)
					}
				}
			}
		}
	}
}
