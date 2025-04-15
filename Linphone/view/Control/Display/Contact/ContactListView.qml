import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp 1.0
import ConstantsCpp 1.0
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ListView {
	id: mainItem

	property string title
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
	property FriendGui highlightedContact

	// Model properties
	// set searchBarText without specifying a model to bold
	// matching names
	property string searchText
	property ConferenceInfoGui confInfoGui
	
	property bool haveFavorites: false
	property bool haveContacts: count > 0
    property real sectionsPixelSize: Typography.h4.pixelSize
    property real sectionsWeight: Typography.h4.weight
    property real sectionsSpacing: Math.round(18 * DefaultStyle.dp)
	
    property real itemsRightMargin: Math.round(39 * DefaultStyle.dp)
	property bool expanded: true
    property real headerHeight: headerItem?.height
	
	signal contactDeletionRequested(FriendGui contact)
	signal contactSelected(FriendGui contact)	// Click/Space/Enter
	signal addContactToSelection(var address)
	signal removeContactFromSelection(var indexInSelection)
	signal updatePosition()
	
	clip: true
	highlightFollowsCurrentItem: false
	cacheBuffer: 400
	implicitHeight: contentHeight
    spacing: expanded ? Math.round(4 * DefaultStyle.dp) : 0

    onVisibleChanged: if (visible && !expanded) expanded = true
	
	property var _currentItemY: currentItem?.y
	on_CurrentItemYChanged: if(_currentItemY){
		updatePosition()
	}
	onYChanged: updatePosition()
	
	// Qt bug: sometimes, containsMouse may not be send and update on each MouseArea.
	// So we need to use this variable to switch off all hovered items.
	property int lastMouseContainsIndex: -1
		
	property bool _moveToIndex: false
	
	function selectIndex(index){
		if(mainItem.expanded && index >= 0){
			mainItem.currentIndex = index
			var item = itemAtIndex(mainItem.currentIndex)
			if(item){// Item is ready and available
				mainItem.highlightedContact = item.searchResultItem
				item.forceActiveFocus()
				updatePosition()
				_moveToIndex = false
			}else{// Move on the next items load.
				// If visible, try to wait loading
				_moveToIndex = visible
			}
		}else{
			mainItem.currentIndex = -1
			mainItem.highlightedContact = null
			if(headerItem) {
				headerItem.forceActiveFocus()
			}
			_moveToIndex = false
		}
	}
	onContactSelected: updatePosition()
	onExpandedChanged: if(!expanded) updatePosition()
	keyNavigationEnabled: false
	Keys.onPressed: (event)=> {
		if(event.key == Qt.Key_Up || event.key == Qt.Key_Down){
			if(event.key == Qt.Key_Up && !headerItem.activeFocus) {
				if(currentIndex >= 0 ) {
					selectIndex(mainItem.currentIndex-1)
					event.accepted = true;
				}
			}else if(event.key == Qt.Key_Down && mainItem.expanded){
				if(currentIndex < model.count - 1) {
					selectIndex(mainItem.currentIndex+1)
					event.accepted = true;
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
	// Workaround: itemAtIndex and count are decorellated and are not enough to know when the ListView has load all its children.
	// So when itemAtIndex is not available, start this timer along count changed signal.
	Timer{
		id: delaySelection
		interval: 100
		running: _moveToIndex
		onTriggered: {
			_moveToIndex = false
			if(count > mainItem.currentIndex) selectIndex(mainItem.currentIndex)
			else{
				_moveToIndex = true
			}
		}
	}
	
	header: FocusScope{
		id: headerItem
		width: mainItem.width
		height: headerContents.implicitHeight
				
		ColumnLayout {
			id: headerContents
			width: parent.width
			spacing: 0
			Item{// Do not use directly RowLayout : there is an issue where the layout doesn't update on visible
				Layout.fillWidth: true
				Layout.preferredHeight: mainItem.count > 0 ? headerTitleLayout.implicitHeight : 0
                Layout.bottomMargin: Math.round(4 * DefaultStyle.dp)
				RowLayout {
					id: headerTitleLayout
					anchors.fill: parent
					spacing: 0
					// Need this because it can stay at 0 on display without manual relayouting (moving position, resize)
					visible: mainItem.count > 0
					Text {
						text: mainItem.title
						font {
							pixelSize: sectionsPixelSize
							weight: sectionsWeight
						}
					}
					Item {
						Layout.fillWidth: true
					}
					Button {
						id: headerExpandButton
						style: ButtonStyle.noBackground
						icon.source: mainItem.expanded ? AppIcons.upArrow : AppIcons.downArrow
						Layout.fillHeight: true
						Layout.preferredWidth: height
                        Layout.rightMargin: Math.round(23 * DefaultStyle.dp)
                        icon.width: Math.round(24 * DefaultStyle.dp)
                        icon.height: Math.round(24 * DefaultStyle.dp)
						focus: true
						onClicked: mainItem.expanded = !mainItem.expanded
					}
				}
			}
		}
	}
	
	delegate: ContactListItem{
		id: contactItem
		width: mainItem.width
		focus: true
		visible: mainItem.expanded
		searchResultItem: $modelData
		showInitials: mainItem.showInitials && isStored
		showDefaultAddress: mainItem.showDefaultAddress
		showActions: mainItem.showActions
		showContactMenu: mainItem.showContactMenu && searchResultItem.core.isStored
		highlightText: mainItem.highlightText
		displayNameCapitalization: mainItem.displayNameCapitalization
		
		selectionEnabled: mainItem.selectionEnabled
		multiSelectionEnabled: mainItem.multiSelectionEnabled
		selectedContacts: mainItem.selectedContacts
		isSelected: mainItem.highlightedContact && mainItem.highlightedContact.core == searchResultItem.core
		isLastHovered: mainItem.lastMouseContainsIndex == index
		previousInitial: mainItem.itemAtIndex(index-1)?.initial
		itemsRightMargin: mainItem.itemsRightMargin
		
		onIsSelectedChanged: if(isSelected) mainItem.currentIndex = index
		onContactDeletionRequested: (contact) => mainItem.contactDeletionRequested(contact)

		onClicked: (mouse) => {
		   if (mouse && mouse.button == Qt.RightButton) {
			   friendPopup.open()
		   } else {
				forceActiveFocus()
				mainItem.highlightedContact = contactItem.searchResultItem
				if (mainItem.multiSelectionEnabled) {
					var indexInSelection = mainItem.selectedContacts.indexOf(searchResultItem.core.defaultAddress)
					if (indexInSelection == -1) {
						mainItem.addContactToSelection(searchResultItem.core.defaultAddress)
					}
					else {
						mainItem.removeContactFromSelection(indexInSelection)
					}
				}
				mainItem.contactSelected(searchResultItem)
			}
		}
		onContainsMouseChanged: (containsMouse) => {
			if(containsMouse)
				mainItem.lastMouseContainsIndex = index
			else if( mainItem.lastMouseContainsIndex == index)
				mainItem.lastMouseContainsIndex = -1
		}
	}
}
