import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import Linphone.Styles 1.0

// =============================================================================

SearchBox {
	id: searchBox
	
	// ---------------------------------------------------------------------------
	
	readonly property alias isOpen: searchBox._isOpen
	property alias header : view.headerItem
	property alias actions : view.actions
	property alias showHeader : view.showHeader
	property string previousText: text
	onTextChanged: if( text != '') previousText = text;
	
	property alias participantListModel : searchModel.participantListModel
	
	function addAddressToIgnore(entry){
		searchModel.addAddressToIgnore(entry)
	}
	
	function removeAddressToIgnore(entry){
		searchModel.removeAddressToIgnore(entry)
	}
	
	function isIgnored(address){
		return searchModel.isIgnored(address)
	}
	property var resultExceptions : []
	
	// ---------------------------------------------------------------------------
	
	signal addContact (string sipAddress)
	signal launchChat (string sipAddress)
	signal launchSecureChat (string sipAddress)
	signal launchCall (string sipAddress)
	signal launchVideoCall (string sipAddress)
	
	signal entryClicked (var entry)
	
	// ---------------------------------------------------------------------------
	
	entryHeight: SipAddressesViewStyle.entry.height
	
	// ---------------------------------------------------------------------------
	
	onEnterPressed: {
		var sipAddress = view.interpretableSipAddress
		return sipAddress.length > 0 && SettingsModel.outgoingCallsEnabled && searchBox.launchCall(sipAddress)
	}
	
	// ---------------------------------------------------------------------------
	
	SipAddressesView {
		id: view
		
		actions: [{
				colorSet: SipAddressesViewStyle.videoCall,
				secure: 0,
				visible: true,
				handler: function (entry) {
					searchBox.closeMenu()
					searchBox.launchVideoCall(entry.sipAddress)
				},
				visible: SettingsModel.videoEnabled && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton
			}, {
				colorSet: SipAddressesViewStyle.call,
				secure: 0,
				visible: true,
				handler: function (entry) {
					searchBox.closeMenu()
					searchBox.launchCall(entry.sipAddress)
				},
				visible: SettingsModel.outgoingCallsEnabled
			}, {
				colorSet: SettingsModel.getShowStartChatButton() ? SipAddressesViewStyle.chat : SipAddressesViewStyle.history,
				secure: 0,
				handler: function (entry) {
					searchBox.closeMenu()
					searchBox.launchChat(entry.sipAddress)
				},
				visible: SettingsModel.standardChatEnabled,
				zz: 'toto'
			}, {
				colorSet: SettingsModel.getShowStartChatButton() ? SipAddressesViewStyle.chat : SipAddressesViewStyle.history,
				secure: 1,
				visible: SettingsModel.secureChatEnabled && AccountSettingsModel.conferenceUri != '',
				handler: function (entry) {
					searchBox.closeMenu()
					searchBox.launchSecureChat(entry.sipAddress)
				}
			}
			
		]
		
		headerButtonDescription: qsTr('addContact')
		headerButtonIcon: 'contact_add_custom'
		headerButtonOverwriteColor: SipAddressesViewStyle.header.button.colorModel.color
		headerButtonAction: SettingsModel.contactsEnabled && (function (sipAddress) {
			searchBox.closeMenu()
			searchBox.addContact(sipAddress)
		})
		
		genSipAddress: searchBox.filter
		
		model: SearchSipAddressesProxyModel {
			id:searchModel
		}
		
		onEntryClicked: {
			searchBox.closeMenu()
			searchBox.entryClicked(entry)
		}
	}
}
