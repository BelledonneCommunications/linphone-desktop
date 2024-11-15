import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp


ListView {
	id: mainItem

	property bool showInitials: true	// Display Initials of Display name.
	property bool showDefaultAddress: true	// Display address below display name.
	property bool showActions: false	// Display actions layout (call buttons)
	property bool showContactMenu: true	// Display the dot menu for contacts.
	property bool showFavorites: true	// Display the favorites in the header
	property bool hideSuggestions: false	// Hide not stored contacts (not suggestions)
	property string highlightText	// Bold characters in Display name.
	property var sourceFlags: LinphoneEnums.MagicSearchSource.All
	
	property bool displayNameCapitalization: true	// Capitalize display name.
	
	property bool selectionEnabled: true		// Contact can be selected
	property bool multiSelectionEnabled: false	//Multiple items can be selected.
	property list<string> selectedContacts		// List of default address on selected contacts.
	property FriendGui selectedContact//: model.getAt(currentIndex) || null
		
	property bool searchOnInitialization: false
	property bool loading: false
	property bool pauseSearch: false // true = don't search on text change

	// Model properties
	// set searchBarText without specifying a model to bold
	// matching names
	property string searchBarText
	property string searchText// Binding is done on searchBarTextChanged
	property ConferenceInfoGui confInfoGui
	
	property bool haveFavorites: false
	property int sectionsPixelSize: 16 * DefaultStyle.dp
	property int sectionsWeight: 800 * DefaultStyle.dp
	property int sectionsSpacing: 18 * DefaultStyle.dp
	
	property int itemsRightMargin: 39 * DefaultStyle.dp
	
	signal resultsReceived()
	signal contactStarredChanged()
	signal contactDeletionRequested(FriendGui contact)
	signal contactAddedToSelection(string address)
	signal contactRemovedFromSelection(string address)
	signal contactClicked(FriendGui contact)
	
	clip: true
	highlightFollowsCurrentItem: true
	cacheBuffer: 400
	// Binding loop hack
	onContentHeightChanged: Qt.callLater(function(){cacheBuffer = Math.max(0,contentHeight)})

	function selectContact(address) {
		var index = magicSearchProxy.findFriendIndexByAddress(address)
		if (index != -1) {
			mainItem.currentIndex = index
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
	
	onResultsReceived: {
		loading = false
		mainItem.positionViewAtBeginning()
	}
	onSearchBarTextChanged: {
		loading = true
		if(!pauseSearch) {
			searchText = searchBarText.length === 0 ? "*" : searchBarText
		}
	}
	onPauseSearchChanged: {
		if(!pauseSearch){
			searchText = searchBarText.length === 0 ? "*" : searchBarText
		}
	}
	onAtYEndChanged: if(atYEnd) magicSearchProxy.displayMore()
	keyNavigationEnabled: false
	Keys.onPressed: (event)=> {
		if(header.activeFocus) return;
		if(event.key == Qt.Key_Up || event.key == Qt.Key_Down){
			if (currentIndex == 0 && event.key == Qt.Key_Up) {
				if( headerItem.list.count > 0) {
					mainItem.highlightFollowsCurrentItem = false
					currentIndex = -1
					headerItem.list.currentIndex = headerItem.list.count -1
					var item = headerItem.list.itemAtIndex(headerItem.list.currentIndex)
					mainItem.selectedContact = item.searchResultItem
					item.forceActiveFocus()
					headerItem.updatePosition()
					event.accepted = true;
				}else{
					mainItem.currentIndex = mainItem.count - 1
					var item = itemAtIndex(mainItem.currentIndex)
					mainItem.selectedContact = item.searchResultItem
					item.forceActiveFocus()
					event.accepted = true;
				}
			}else if(currentIndex >= mainItem.count -1 && event.key == Qt.Key_Down){
				if( headerItem.list.count > 0) {
					mainItem.highlightFollowsCurrentItem = false
					mainItem.currentIndex = -1
					headerItem.list.currentIndex = 0
					var item = headerItem.list.itemAtIndex(headerItem.list.currentIndex)
					mainItem.selectedContact = item.searchResultItem
					item.forceActiveFocus()
					headerItem.updatePosition()
					event.accepted = true;
				}else{
					mainItem.currentIndex = 0
					var item = itemAtIndex(mainItem.currentIndex)
					mainItem.selectedContact = item.searchResultItem
					item.forceActiveFocus()
					event.accepted = true;
				}
			}else if(event.key == Qt.Key_Up){
				mainItem.highlightFollowsCurrentItem = true
				var item = itemAtIndex(--mainItem.currentIndex)
				mainItem.selectedContact = item.searchResultItem
				item.forceActiveFocus()
				event.accepted = true;
			}else if(event.key == Qt.Key_Down){
				mainItem.highlightFollowsCurrentItem = true
				var item = itemAtIndex(++mainItem.currentIndex)
				mainItem.selectedContact = item.searchResultItem
				item.forceActiveFocus()
				event.accepted = true;
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

	Control.ScrollBar.vertical: ScrollBar {
		id: scrollbar
		rightPadding: 8 * DefaultStyle.dp
		topPadding: mainItem.haveFavorites ? 24 * DefaultStyle.dp : 0	// Avoid to be on top of collapse button
		
		active: true
		interactive: true
		policy: mainItem.contentHeight > mainItem.height ? Control.ScrollBar.AlwaysOn : Control.ScrollBar.AlwaysOff
	}
	
	model: MagicSearchProxy {
		id: magicSearchProxy
		searchText: mainItem.searchText
		aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
		sourceFlags: mainItem.sourceFlags
					   
		hideSuggestions: mainItem.hideSuggestions
		initialDisplayItems: 20
		onLocalFriendCreated: (index) => {
			var item = itemAtIndex(index)
			if(item){
				mainItem.currentIndex = index
				mainItem.selectedContact = item.searchResultItem
				item.forceActiveFocus()
			}
		}
		onInitialized: {
			mainItem.loading = true
			magicSearchProxy.forceUpdate()
		}
		onModelReset: mainItem.resultsReceived()
	}
	
	section.property: "isStored"
	//section.criteria: ViewSection.FirstCharacter
	section.delegate: Item{
			width: mainItem.width
			height: textItem.implicitHeight + sectionsSpacing * 2				
			required property bool section
			Text {
				id: textItem
				anchors.fill: parent
				text: section ? qsTr("Contacts") : qsTr("Suggestions")
				horizontalAlignment: Text.AlignLeft
				verticalAlignment: Text.AlignVCenter
				font {
					pixelSize: sectionsPixelSize
					weight: sectionsWeight
				}
			}
			
		}
	header: FocusScope{
				id: headerItem
				width: mainItem.width
				height: favoritesContents.implicitHeight
				property alias list: favoriteList
				
				// Hack because changing currentindex change focus.
				Timer{
					id: focusDelay
					interval: 10
					onTriggered: {
						mainItem.highlightFollowsCurrentItem = !headerItem.activeFocus
					}
				}
				onActiveFocusChanged:focusDelay.restart()
				//---------------------------------------------------
				
				function updatePosition(){
					var item = favoriteList.itemAtIndex(favoriteList.currentIndex)
					if( item){
						// For debugging just in case
						//var listPosition = item.mapToItem(favoriteList, item.x, item.y)
						//var newPosition = favoriteList.mapToItem(mainItem, listPosition.x, listPosition.y)
						//console.log("item pos: " +item.x + " / " +item.y)
						//console.log("fav pos: " +favoriteList.x + " / " +favoriteList.y)
						//console.log("fav content: " +favoriteList.contentX + " / " +favoriteList.contentY)
						//console.log("main pos: " +mainItem.x + " / " +mainItem.y)
						//console.log("main content: " +mainItem.contentX + " / " +mainItem.contentY)
						//console.log("list pos: " +listPosition.x + " / " +listPosition.y)
						//console.log("new pos: " +newPosition.x + " / " +newPosition.y)
						//console.log("header pos: " +headerItem.x + " / " +headerItem.y)
						//console.log("Moving to " + (headerItem.y+item.y))
						mainItem.contentY = headerItem.y+item.y
					}
					
				}
				
				ColumnLayout {
					id: favoritesContents
					width: parent.width
					spacing: mainItem.haveFavorites ? sectionsSpacing : 0
					BusyIndicator {
						Layout.alignment: Qt.AlignCenter
						Layout.preferredHeight: visible ? 60 * DefaultStyle.dp : 0
						Layout.preferredWidth: 60 * DefaultStyle.dp
						indicatorHeight: 60 * DefaultStyle.dp
						indicatorWidth: 60 * DefaultStyle.dp
						visible: mainItem.loading
						indicatorColor: DefaultStyle.main1_500_main
						
					}
					Item{// Do not use directly RowLayout : there is an issue where the layout doesn't update on visible
						Layout.fillWidth: true
						Layout.preferredHeight: mainItem.haveFavorites ? favoriteTitle.implicitHeight : 0
						RowLayout {
							id: favoriteTitle
							anchors.fill: parent
							spacing: 0
							
							// Need this because it can stay at 0 on display without manual relayouting (moving position, resize)
							visible: mainItem.haveFavorites
							onVisibleChanged: if(visible) {
												Qt.callLater(mainItem.positionViewAtBeginning)// If not later, the view will not move to favoris at startup
											  }
							Text {
								//Layout.fillHeight: true
								text: qsTr("Favoris")
								font {
									pixelSize: sectionsPixelSize
									weight: sectionsWeight
								}
							}
							Item {
								Layout.fillWidth: true
							}
							Button {
								id: favoriteExpandButton
								background: Item{}
								icon.source: favoriteList.visible ? AppIcons.upArrow : AppIcons.downArrow
								Layout.fillHeight: true
								Layout.preferredWidth: height
								//Layout.preferredWidth: 24 * DefaultStyle.dp
								//Layout.preferredHeight: 24 * DefaultStyle.dp
								Layout.rightMargin: 23 * DefaultStyle.dp 
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								focus: true
								onClicked: favoriteList.visible = !favoriteList.visible
								KeyNavigation.down: favoriteList
							}
						}
					}
					ListView{
						id: favoriteList
						Layout.fillWidth: true
						Layout.preferredHeight: count > 0 ? contentHeight : 0// Show full and avoid scrolling
						
						
						
						onCountChanged: mainItem.haveFavorites = count > 0
						Keys.onPressed: (event)=> {
							if(event.key == Qt.Key_Up || event.key == Qt.Key_Down) {
								if (favoriteList.currentIndex == 0 && event.key == Qt.Key_Up) {
									if( mainItem.count > 0) {
										mainItem.highlightFollowsCurrentItem = true
										favoriteList.currentIndex = -1
										mainItem.currentIndex = mainItem.count-1
										var item = mainItem.itemAtIndex(mainItem.currentIndex)
										mainItem.selectedContact = item.searchResultItem
										item.forceActiveFocus()
										event.accepted = true;
									}else{
										favoriteList.currentIndex = favoriteList.count - 1
										var item = itemAtIndex(favoriteList.currentIndex)
										mainItem.selectedContact = item.searchResultItem
										item.forceActiveFocus()
										event.accepted = true;			
									}
								}else if(currentIndex >= favoriteList.count -1 && event.key == Qt.Key_Down) {
									if( mainItem.count > 0) {
										mainItem.highlightFollowsCurrentItem = true
										favoriteList.currentIndex = -1
										mainItem.currentIndex = 0
										var item = mainItem.itemAtIndex(mainItem.currentIndex)
										mainItem.selectedContact = item.searchResultItem
										item.forceActiveFocus()
										event.accepted = true;
									}else{
										favoriteList.currentIndex = 0
										var item = itemAtIndex(favoriteList.currentIndex)
										mainItem.selectedContact = item.searchResultItem
										item.forceActiveFocus()
										event.accepted = true;			
									}
								}else if(event.key == Qt.Key_Up){
									mainItem.highlightFollowsCurrentItem = false
									var item = itemAtIndex(--favoriteList.currentIndex)
									mainItem.selectedContact = item.searchResultItem
									item.forceActiveFocus()
									headerItem.updatePosition()
									event.accepted = true;
								}else if(event.key == Qt.Key_Down){
									mainItem.highlightFollowsCurrentItem = false
									var item = itemAtIndex(++favoriteList.currentIndex)
									mainItem.selectedContact = item.searchResultItem
									item.forceActiveFocus()
									headerItem.updatePosition()
									event.accepted = true;
								}
							}
						}
						property MagicSearchProxy proxy: MagicSearchProxy{
							parentProxy: mainItem.model
							showFavoritesOnly: true
							hideSuggestions: mainItem.hideSuggestions
						}
						model : showFavorites && mainItem.searchBarText == '' ? proxy : []
						delegate: ContactListItem{
							width: favoriteList.width
							focus: true
							
							searchResultItem: $modelData
							showInitials: mainItem.showInitials
							showDefaultAddress: mainItem.showDefaultAddress
							showActions: mainItem.showActions
							showContactMenu: mainItem.showContactMenu
							highlightText: mainItem.highlightText
							
							displayNameCapitalization: mainItem.displayNameCapitalization
							itemsRightMargin: mainItem.itemsRightMargin
							selectionEnabled: mainItem.selectionEnabled
							multiSelectionEnabled: mainItem.multiSelectionEnabled
							selectedContacts: mainItem.selectedContacts
							isSelected: mainItem.selectedContact &&  mainItem.selectedContact.core == searchResultItem.core
							previousInitial: ''//favoriteList.count > 0 ? favoriteList.itemAtIndex(index-1)?.initial : ''	// Binding on count
							initial: ''	// Hide initials but keep space
							
							onIsSelectedChanged: if(isSelected) favoriteList.currentIndex = index
							onContactStarredChanged: mainItem.contactStarredChanged()
							onContactDeletionRequested: (contact) => mainItem.contactDeletionRequested(contact)
							onClicked: (mouse) => {
								mainItem.highlightFollowsCurrentItem = false
								favoriteList.currentIndex = index
								mainItem.selectedContact = searchResultItem
								forceActiveFocus()
								headerItem.updatePosition()
								if (mainItem.multiSelectionEnabled) {
									var indexInSelection = mainItem.selectedContacts.indexOf(searchResultItem.core.defaultAddress)
									if (indexInSelection == -1) {
										mainItem.addContactToSelection(searchResultItem.core.defaultAddress)
									}
									else {
										mainItem.removeContactFromSelection(indexInSelection, 1)
									}
								}
								mainItem.contactClicked(searchResultItem)
							}
						}
					}
				}
			}
	
	delegate: ContactListItem{
		id: contactItem
		width: mainItem.width
		focus: true
		
		searchResultItem: $modelData
		showInitials: mainItem.showInitials && searchResultItem.core.isStored
		showDefaultAddress: mainItem.showDefaultAddress
		showActions: mainItem.showActions
		showContactMenu: searchResultItem.core.isStored
		highlightText: mainItem.highlightText
		
		displayNameCapitalization: mainItem.displayNameCapitalization
		itemsRightMargin: mainItem.itemsRightMargin
		
		selectionEnabled: mainItem.selectionEnabled
		multiSelectionEnabled: mainItem.multiSelectionEnabled
		selectedContacts: mainItem.selectedContacts
		isSelected: mainItem.selectedContact && mainItem.selectedContact.core == searchResultItem.core
		previousInitial: mainItem.itemAtIndex(index-1)?.initial
		
		onIsSelectedChanged: if(isSelected) mainItem.currentIndex = index
		onContactStarredChanged: mainItem.contactStarredChanged()
		onContactDeletionRequested: (contact) => mainItem.contactDeletionRequested(contact)
		onClicked: (mouse) => {
			mainItem.highlightFollowsCurrentItem = true
		   if (mouse && mouse.button == Qt.RightButton) {
			   friendPopup.open()
		   } else {
			   forceActiveFocus()
				if(mainItem.selectedContact && mainItem.selectedContact.core != contactItem.searchResultItem.core)
					headerItem.list.currentIndex = -1
				mainItem.selectedContact = contactItem.searchResultItem
			   if (mainItem.multiSelectionEnabled) {
				   var indexInSelection = mainItem.selectedContacts.indexOf(searchResultItem.core.defaultAddress)
				   if (indexInSelection == -1) {
					   mainItem.addContactToSelection(searchResultItem.core.defaultAddress)
				   }
				   else {
					   mainItem.removeContactFromSelection(indexInSelection, 1)
				   }
			   }
			   mainItem.contactClicked(searchResultItem)
		   }
		}
	}
}
