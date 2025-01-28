import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

Flickable{
	id: mainItem
	
	property bool showInitials: true	// Display Initials of Display name.
	property bool showDefaultAddress: true	// Display address below display name.
	property bool showActions: false	// Display actions layout (call buttons)
	property bool showContactMenu: true	// Display the dot menu for contacts.
	property bool showFavorites: true	// Display the favorites in the header
	property bool hideSuggestions: false	// Hide not stored contacts (not suggestions)
	property string highlightText: searchText	// Bold characters in Display name.
	property var sourceFlags: LinphoneEnums.MagicSearchSource.All
	
	property bool displayNameCapitalization: true	// Capitalize display name.
	
	property bool selectionEnabled: true		// Contact can be selected
	property bool multiSelectionEnabled: false	//Multiple items can be selected.
	property list<string> selectedContacts		// List of default address on selected contacts.
	//property FriendGui selectedContact//: model.getAt(currentIndex) || null
	property FriendGui highlightedContact
		
	property bool searchOnEmpty: true
	property bool loading: false
	property bool pauseSearch: false // true = don't search on text change

	// Model properties
	// set searchBarText without specifying a model to bold
	// matching names
	property string searchBarText
	property string searchText// Binding is done on searchBarTextChanged
	property ConferenceInfoGui confInfoGui
	
	property bool haveFavorites: false
	property bool haveContacts: count > 0
	property int sectionsPixelSize: 16 * DefaultStyle.dp
	property int sectionsWeight: 800 * DefaultStyle.dp
	property int sectionsSpacing: 18 * DefaultStyle.dp
	
	property int itemsRightMargin: 39 * DefaultStyle.dp
	property int count: contactsList.count + suggestionsList.count + favoritesList.count
	
	signal resultsReceived()
	signal contactStarredChanged()
	signal contactDeletionRequested(FriendGui contact)
	signal contactAddedToSelection(string address)
	signal contactRemovedFromSelection(string address)
	signal contactSelected(FriendGui contact)
	
	contentWidth: width
	contentHeight: contentsLayout.height

	
	function selectContact(address) {
		var index = contactsProxy.loadUntil(address)// Be sure to have this address in proxy if it exists
		if (index != -1) {
			contactsList.selectIndex(index)
		}
		return index
		
	}
	function addContactToSelection(address) {
		if (multiSelectionEnabled) {
			var indexInSelection = selectedContacts.indexOf(address)
			if (indexInSelection == -1) {
				selectedContacts.push(address)
				contactAddedToSelection(address)
			}
		}
	}
	function removeContactFromSelection(indexInSelection) {
		var addressToRemove = selectedContacts[indexInSelection]
		if (indexInSelection != -1) {
			selectedContacts.splice(indexInSelection, 1)
			contactRemovedFromSelection(addressToRemove)
		}
	}
	function removeSelectedContactByAddress(address) {
		var index = selectedContacts.indexOf(address)
		if (index != -1) {
			selectedContacts.splice(index, 1)
			contactRemovedFromSelection(address)
		}
	}
	function haveAddress(address){
		var index = magicSearchProxy.findFriendIndexByAddress(address)
		return  index != -1
	}
	
	function resetSelections(){
		mainItem.highlightedContact = null
		favoritesList.currentIndex = -1
		contactsList.currentIndex = -1
		suggestionsList.currentIndex = -1
	}

	function findNextList(item, count, direction){
		if(count == 3) return null
		var nextItem
		switch(item){
		case suggestionsList:nextItem=(direction > 0 ? favoritesList : contactsList);break;
		case contactsList:nextItem=(direction > 0 ? suggestionsList : favoritesList);break;
		case favoritesList:nextItem=(direction > 0 ? contactsList : suggestionsList);break;
		default: return null
		}
		if( nextItem.model.count > 0) return nextItem
		else return findNextList(nextItem, count+1, direction)
	}
	
	function updatePosition(list){
		Utils.updatePosition(mainItem, list)
	}
	
	onHighlightedContactChanged:{
		favoritesList.highlightedContact = highlightedContact
		contactsList.highlightedContact = highlightedContact
		suggestionsList.highlightedContact = highlightedContact
	}
	
	onResultsReceived: {
		loading = false
		mainItem.contentY = 0
	}
	onSearchBarTextChanged: {
		if(!pauseSearch && (mainItem.searchOnEmpty || searchBarText != '')) {
			searchText = searchBarText.length === 0 ? "*" : searchBarText
		}
	}
	onPauseSearchChanged: {
		if(!pauseSearch && (mainItem.searchOnEmpty || searchBarText != '')){
			searchText = searchBarText.length === 0 ? "*" : searchBarText
		}
	}
	onSearchTextChanged: loading = true
	onAtYEndChanged: if(atYEnd) {
		if( (contactsProxy.haveMore && contactList.expanded ) || mainItem.hideSuggestions) contactsProxy.displayMore()
		else suggestionsProxy.displayMore()
	}
	Behavior on contentY{
		NumberAnimation {
			duration: 500
			easing.type: Easing.OutExpo
		}
	}
	Keys.onPressed: (event)=> {
		if(!event.accepted){
			if(event.key == Qt.Key_Up || event.key == Qt.Key_Down){	
				var newItem
				var direction = (event.key == Qt.Key_Up ? -1 : 1)
				if(suggestionsList.activeFocus) newItem = findNextList(suggestionsList, 0, direction)
				else if(contactsList.activeFocus) newItem = findNextList(contactsList, 0, direction)
				else if(favoritesList.activeFocus) newItem = findNextList(favoritesList, 0, direction)
				else newItem = findNextList(suggestionsList, 0, direction)
				if(newItem){
					newItem.selectIndex(direction > 0 ? -1 : newItem.model.count - 1)
					event.accepted = true
				}
			}
		}
	}
	Component.onCompleted: {
		if (confInfoGui) {
			for(var i = 0; i < confInfoGui.core.participants.length; ++i) {
				selectedContacts.push(confInfoGui.core.getParticipantAddressAt(i));
			}
		}
	}
	
	Connections {
		target: SettingsCpp
		onLdapConfigChanged: {
			if (SettingsCpp.syncLdapContacts)
				magicSearchProxy.forceUpdate()
		}
	}
	
	property MagicSearchProxy mainModel: MagicSearchProxy {
		id: magicSearchProxy
		searchText: mainItem.searchText
		aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
		sourceFlags: mainItem.sourceFlags
		onModelReset: {
			mainItem.resetSelections()
			mainItem.resultsReceived()
		}
		
		onInitialized: {
			if(mainItem.searchOnEmpty || searchText != '' ) {
				mainItem.loading = true
				forceUpdate()
			}
		}
	}
	

	Control.ScrollBar.vertical: ScrollBar {
		id: scrollbar
		rightPadding: 8 * DefaultStyle.dp
		topPadding: mainItem.haveFavorites ? 24 * DefaultStyle.dp : 0	// Avoid to be on top of collapse button
		
		active: true
		interactive: true
		policy: mainItem.contentHeight > mainItem.height ? Control.ScrollBar.AlwaysOn : Control.ScrollBar.AlwaysOff
	}
	
	
	ColumnLayout{
		id: contentsLayout
		width: parent.width
		spacing: 20 * DefaultStyle.dp
		BusyIndicator {
			Layout.alignment: Qt.AlignCenter
			Layout.preferredHeight: visible ? 60 * DefaultStyle.dp : 0
			Layout.preferredWidth: 60 * DefaultStyle.dp
			indicatorHeight: 60 * DefaultStyle.dp
			indicatorWidth: 60 * DefaultStyle.dp
			visible: mainItem.loading
			indicatorColor: DefaultStyle.main1_500_main
		}
		
		ContactListView{
			id: favoritesList
			visible: contentHeight > 0
			Layout.fillWidth: true
			Layout.preferredHeight: implicitHeight
			interactive: false
			highlightText: mainItem.highlightText
			showActions: mainItem.showActions
			showInitials: mainItem.showInitials
			showContactMenu: mainItem.showContactMenu
			showDefaultAddress: mainItem.showDefaultAddress
			selectionEnabled: mainItem.selectionEnabled
			multiSelectionEnabled: mainItem.multiSelectionEnabled
			selectedContacts: mainItem.selectedContacts
			title: qsTr('Favoris')
			
			onHighlightedContactChanged: mainItem.highlightedContact = highlightedContact
			onContactSelected: (contactGui) => {
				mainItem.contactSelected(contactGui)
			}
			onUpdatePosition: mainItem.updatePosition(favoritesList)
			onContactDeletionRequested: (contact) => {mainItem.contactDeletionRequested(contact)}
			onAddContactToSelection: (address) => {mainItem.addContactToSelection(address)}
			onRemoveContactFromSelection: (index) => {mainItem.removeContactFromSelection(index)}
			
			property MagicSearchProxy proxy: MagicSearchProxy {
				parentProxy: mainItem.mainModel
				filterType: MagicSearchProxy.FilteringTypes.Favorites
			}
			model : mainItem.showFavorites && (mainItem.searchBarText == ''|| mainItem.searchBarText == '*')? proxy : []
		}
	
		ContactListView{
			id: contactsList
			visible: contentHeight > 0
			Layout.fillWidth: true
			Layout.preferredHeight: implicitHeight
			Layout.topMargin: favoritesList.height > 0 ? 4 * DefaultStyle.dp : 0
			interactive: false
			highlightText: mainItem.highlightText
			showActions: mainItem.showActions
			showInitials: mainItem.showInitials
			showContactMenu: mainItem.showContactMenu
			showDefaultAddress: mainItem.showDefaultAddress
			selectionEnabled: mainItem.selectionEnabled
			multiSelectionEnabled: mainItem.multiSelectionEnabled
			selectedContacts: mainItem.selectedContacts
			title: qsTr('Contacts')
			
			onHighlightedContactChanged: mainItem.highlightedContact = highlightedContact
			onContactSelected: (contactGui) => {
				mainItem.contactSelected(contactGui)
			}
			onUpdatePosition: mainItem.updatePosition(contactsList)
			onContactDeletionRequested: (contact) => {mainItem.contactDeletionRequested(contact)}
			onAddContactToSelection: (address) => {mainItem.addContactToSelection(address)}
			onRemoveContactFromSelection: (index) => {mainItem.removeContactFromSelection(index)}
						
			model:MagicSearchProxy {
				id: contactsProxy
				parentProxy: mainItem.mainModel
				filterType: MagicSearchProxy.FilteringTypes.App 
							| (mainItem.searchText != '*' && mainItem.searchText != '' || SettingsCpp.syncLdapContacts ? MagicSearchProxy.FilteringTypes.Ldap | MagicSearchProxy.FilteringTypes.CardDAV: 0)
				initialDisplayItems: Math.max(20, 2 * mainItem.height / (63 * DefaultStyle.dp))
				displayItemsStep: 3 * initialDisplayItems / 2
				onLocalFriendCreated: (index) => {
					contactsList.selectIndex(index)
				}
			}
		}
		ContactListView{
			id: suggestionsList
			visible: contentHeight > 0
			Layout.fillWidth: true
			Layout.preferredHeight: implicitHeight
			Layout.topMargin: contactsList.height + favoritesList.height > 0 ? 4 * DefaultStyle.dp : 0
			interactive: false
			showInitials: false
			highlightText: mainItem.highlightText
			showActions: mainItem.showActions
			showContactMenu: mainItem.showContactMenu
			showDefaultAddress: mainItem.showDefaultAddress
			selectionEnabled: mainItem.selectionEnabled
			multiSelectionEnabled: mainItem.multiSelectionEnabled
			selectedContacts: mainItem.selectedContacts
			title: qsTr('Suggestions')
			
			onHighlightedContactChanged: mainItem.highlightedContact = highlightedContact
			onContactSelected: (contactGui) => {
				mainItem.contactSelected(contactGui)
			}
			onUpdatePosition: mainItem.updatePosition(suggestionsList)
			onContactDeletionRequested: (contact) => {mainItem.contactDeletionRequested(contact)}
			onAddContactToSelection: (address) => {mainItem.addContactToSelection(address)}
			onRemoveContactFromSelection: (index) => {mainItem.removeContactFromSelection(index)}
			model:MagicSearchProxy {
				id: suggestionsProxy
				parentProxy: mainItem.mainModel
				filterType: mainItem.hideSuggestions ? MagicSearchProxy.FilteringTypes.None : MagicSearchProxy.FilteringTypes.Other
				initialDisplayItems: contactsProxy.haveMore && contactsList.expanded ? 0 : Math.max(20, 2 * mainItem.height / (63 * DefaultStyle.dp))
				onInitialDisplayItemsChanged: maxDisplayItems = initialDisplayItems
				displayItemsStep: 3 * initialDisplayItems / 2
				onModelReset: maxDisplayItems = initialDisplayItems
			}
		}
	}
}
