import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	buttons: [
		TextButtonA {
			text: qsTr('cancel')
			
			onClicked: exit(0)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	descriptionText: qsTr('callSipAddressDescription')
	
	height: CallSipAddressStyle.height + 30
	width: CallSipAddressStyle.width
	
	// ---------------------------------------------------------------------------
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Address selector.
		// -------------------------------------------------------------------------
		
		Item {
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			ColumnLayout {
				anchors.fill: parent
				spacing: CallSipAddressStyle.spacing
				
				TextField {
					id: filter
					
					Layout.fillWidth: true
					
					icon: 'search_custom'
					overwriteColor: CallSipAddressStyle.searchField.color
					
					onTextChanged: sipAddressesModel.setFilter(text)
				}
				
				ScrollableListViewField {
					Layout.fillHeight: true
					Layout.fillWidth: true
					
					SipAddressesView {
						anchors.fill: parent
						
						function launchVideoCall(sipAddress){
							CallsListModel.launchVideoCall(sipAddress)
							exit(1)
						}
						function launchAudioCall(sipAddress){
							CallsListModel.launchAudioCall(sipAddress, "")
							exit(1)
						}
						
						actions: [{
								colorSet: CallSipAddressStyle.videoCall,
								secure:0,
								visible:true,
								handler: function (entry) {
									launchVideoCall(entry.sipAddress)
								},
								visible: SettingsModel.videoSupported && SettingsModel.showStartVideoCallButton,
								handlerSipAddress: function(sipAddress) {
									launchVideoCall(sipAddress)
								}
							}, {
								colorSet: CallSipAddressStyle.call,
								secure:0,
								visible:true,
								handler: function (entry) {
									launchAudioCall(entry.sipAddress)
								},
								handlerSipAddress: function(sipAddress) {
									launchAudioCall(sipAddress)
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
