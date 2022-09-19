import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import ColorsList 1.0

import UtilsCpp 1.0

import 'Timeline.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle {
	id: timeline
	
	// ---------------------------------------------------------------------------
	
	property alias model: view.model
	property string _selectedSipAddress
	property bool showHistoryButton : CoreManager.callLogsCount
	property bool isFilterVisible: searchView.visible || showFilterView
	property bool showFiltersButtons: view.count > 0 || timeline.isFilterVisible || timeline.model.filterFlags > 0
	
	// ---------------------------------------------------------------------------
	
	signal entrySelected (TimelineModel entry)
	signal showHistoryRequest()
	
	// ---------------------------------------------------------------------------
	property bool showFilterView : false
	color: TimelineStyle.color
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		
		// -------------------------------------------------------------------------
		
		Connections {
			target: model
			onSelectedCountChanged:{
				if(selectedCount<=0) {
					view.currentIndex = -1
					timeline.entrySelected('')
				}
			}
			onSelectedChanged : if(timelineModel) timeline.entrySelected(timelineModel)
		}
		// -------------------------------------------------------------------------
		// Legend.
		// -------------------------------------------------------------------------
		
		Rectangle {
			id: legendArea
			Layout.fillWidth: true
			Layout.preferredHeight: TimelineStyle.legend.height
			Layout.alignment: Qt.AlignTop
			color: showHistory.containsMouse?TimelineStyle.legend.backgroundColor.hovered:TimelineStyle.legend.backgroundColor.normal
			visible: showHistoryButton || showFiltersButtons
			
			MouseArea{// no more showing history
				id:showHistory
				anchors.fill:parent
				visible: showFiltersButtons
				onClicked: {
					timeline.showFilterView = !timeline.showFilterView
				}
			}
			RowLayout{
				anchors.fill:parent
				spacing:TimelineStyle.legend.spacing
				Text {
					Layout.preferredHeight: parent.height
					Layout.fillWidth: true
					Layout.leftMargin: TimelineStyle.legend.leftMargin
					visible: showFiltersButtons
					color: TimelineStyle.legend.color
					font.pointSize: TimelineStyle.legend.pointSize
					//: A title for filtering mode.
					text: qsTr('timelineFilter')+' : ' 
						  +(timeline.model.filterFlags == 0 || timeline.model.filterFlags == TimelineProxyModel.AllChatRooms
							//: 'All' The mode for timelines filtering. 
							? qsTr('timelineFilterAll')
							  //: 'Custom' The mode for timelines filtering. 
							: qsTr('timelineFilterCustom'))
					verticalAlignment: Text.AlignVCenter
				}
				
				Icon {
					id:filterButton
					Layout.alignment: Qt.AlignRight
					icon: 'filter_params_custom'
					iconSize: TimelineStyle.legend.iconSize
					overwriteColor: TimelineStyle.legend.color
					visible: showFiltersButtons
					MouseArea{
						anchors.fill:parent
						onClicked:{
							timeline.showFilterView = !timeline.showFilterView
						}
					}
				}
				MouseArea{
					Layout.alignment: Qt.AlignRight
					Layout.fillHeight: true
					Layout.preferredWidth: TimelineStyle.legend.iconSize
					visible: showFiltersButtons
					onClicked:{
						searchView.visible = !searchView.visible
					}
				
					Icon {
						id:searchButton
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter
						property bool searching: searchView.visible
						icon: (searchView.visible? 'close_custom': 'search_custom')
						iconSize: TimelineStyle.legend.iconSize
						overwriteColor: TimelineStyle.legend.color
					}
				}
				MouseArea{
					Layout.alignment: Qt.AlignRight
					Layout.rightMargin: TimelineStyle.legend.lastRightMargin
					Layout.fillHeight: true
					Layout.preferredWidth: TimelineStyle.legend.iconSize
					visible: timeline.showHistoryButton 
					onClicked:{
						showHistoryRequest()
					}
					Icon {
						id:callHistoryButton
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter
						property bool searching: searchView.visible
						icon: 'call_history_custom'
						iconSize: TimelineStyle.legend.iconSize
						overwriteColor: TimelineStyle.legend.color
					}
				}
			}
		}
		// -------------------------------------------------------------------------
		// Filter.
		// -------------------------------------------------------------------------
		Rectangle{
			id:exhaustiveFilterView
			Layout.fillWidth: true
			Layout.preferredHeight: filterChoices.height
			Layout.alignment: Qt.AlignCenter
			border.color: TimelineStyle.filterField.borderColor
			border.width: 2
			visible: timeline.showFilterView && !SettingsModel.useMinimalTimelineFilter
			
			ColumnLayout{
				id:filterChoices
				anchors.leftMargin: 20
				anchors.left:parent.left
				anchors.right:parent.right
				spacing:-4
				function getFilterFlags(){
					return secureFilter.model.get(secureFilter.currentIndex).value | groupFilter.model.get(groupFilter.currentIndex).value | ephemeralsFilter.model.get(ephemeralsFilter.currentIndex).value;
				}
				ComboBox {
					Layout.fillWidth: true
					id:secureFilter
					currentIndex: 0
					onCurrentIndexChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					textRole: "key"
					model:  ListModel {
						ListElement { 
					//: 'All security levels' : Filter item. Selecting it will not do any filter on security level.
							key: qsTr('timelineFilterAllSecureLevelRooms'); value: 0}
						ListElement { 
					//: 'Standard rooms' : Filter item. Selecting it will show all simple rooms.	
							key: qsTr('timelineFilterStandardRooms'); value: TimelineProxyModel.StandardChatRoom}
						ListElement { 
					//: 'Secure rooms' : Filter item. Selecting it will show all secure rooms.
							key: qsTr('timelineFilterSecureRooms'); value: TimelineProxyModel.SecureChatRoom}
					}
					
					haveBorder: false
					haveMargin: false
					backgroundColor: 'transparent'
					visible: SettingsModel.secureChatEnabled && SettingsModel.standardChatEnabled
				}
				ComboBox {
					Layout.fillWidth: true
					id:groupFilter
					currentIndex: 0
					onCurrentIndexChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					textRole: "key"
					model:  ListModel {
						ListElement { 
					//: 'Any conversations' : Filter item. Selecting it will not do any filter on the type of conversations.
							key: qsTr('timelineFilterAnyChatRooms'); value: 0}
						ListElement { 
					//: 'Simple rooms' : Filter item. Selecting it will show all secure chat groups (with more than one participant).
							key: qsTr('timelineFilterSimpleRooms'); value: TimelineProxyModel.SimpleChatRoom}
						ListElement { 
					//: 'Chat groups' : Filter item. Selecting it will show all chat groups (with more than one participant).
							key: qsTr('timelineFilterChatGroups'); value: TimelineProxyModel.GroupChatRoom}
					}
					
					haveBorder: false
					haveMargin: false
					backgroundColor: 'transparent'
					visible: SettingsModel.secureChatEnabled || SettingsModel.standardChatEnabled
				}
				ComboBox {
					Layout.fillWidth: true
					id:ephemeralsFilter
					currentIndex: 0
					onCurrentIndexChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					textRole: "key"
					model:  ListModel {
						ListElement { 
					//: 'Ephemerals on/off' : Filter item. Selecting it will not do any filter on ephemerals activation.
							key: qsTr('timelineFilterAnyEphemerals'); value: 0}
						ListElement { 
					//: 'No Ephemerals' : Filter item. Selecting it will hide all chat rooms where the ephemeral mode has been enabled.
							key: qsTr('timelineFilterNoEphemerals'); value: TimelineProxyModel.NoEphemeralChatRoom}
						ListElement { 
					//: 'Ephemerals' : Filter item. Selecting it will show all chat rooms where the ephemeral mode has been enabled.
							key: qsTr('timelineFilterEphemerals'); value: TimelineProxyModel.EphemeralChatRoom}
					}
					
					haveBorder: false
					haveMargin: false
					backgroundColor: 'transparent'
					visible: SettingsModel.secureChatEnabled || SettingsModel.standardChatEnabled
				}
			}
		}
		Rectangle{
			id:minimalFilterView
			Layout.fillWidth: true
			Layout.preferredHeight: minimalFilterChoices.height
			Layout.alignment: Qt.AlignCenter
			border.color: TimelineStyle.filterField.borderColor
			border.width: 2
			visible: timeline.showFilterView && SettingsModel.useMinimalTimelineFilter
			
			ColumnLayout{
				id:minimalFilterChoices
				anchors.leftMargin: 20
				anchors.left:parent.left
				anchors.right:parent.right
				spacing:-4
				function getFilterFlags(){
					return securedCheckBox.getValue() | groupCheckBox.getValue() | conferenceCheckBox.getValue();
				}
				CheckBoxText {
					id: securedCheckBox
					Layout.fillWidth: true
					visible: SettingsModel.secureChatEnabled && SettingsModel.standardChatEnabled
					//: 'Secure rooms' : Filter item. Selecting it will show all secure rooms.
					text: qsTr('timelineFilterSecureRooms')
					
					onClicked: {
						timeline.model.filterFlags = minimalFilterChoices.getFilterFlags()
					}
					function getValue(){
						if( checked)
							return TimelineProxyModel.SecureChatRoom
						else
							return 0
					}
				}
				CheckBoxText {
					id: groupCheckBox
					Layout.fillWidth: true
					visible: SettingsModel.secureChatEnabled || SettingsModel.standardChatEnabled
					//: 'Chat groups' : Filter item. Selecting it will show all chat groups (with more than one participant).
					text: qsTr('timelineFilterChatGroups')
					
					onClicked: {
						timeline.model.filterFlags = minimalFilterChoices.getFilterFlags()
					}
					function getValue(){
						if( checked)
							return TimelineProxyModel.GroupChatRoom
						else
							return 0
					}
				}
				
				CheckBoxText {
					id: conferenceCheckBox
					Layout.fillWidth: true
					visible: false
					//: 'Conferences' : Filter item. Selecting it will show all conferences.
					text: qsTr('timelineFilterConferences')
					
					onClicked: {
						timeline.model.filterFlags = minimalFilterChoices.getFilterFlags()
					}
					function getValue(){
							return 0
					}
				}
			}
		}
		// -------------------------------------------------------------------------
		// Search.
		// -------------------------------------------------------------------------
		Rectangle{
			id:searchView
			Layout.fillWidth: true
			Layout.preferredHeight: 40
			Layout.alignment: Qt.AlignCenter
			border.color: TimelineStyle.searchField.borderColor
			border.width: 2
			visible:false
			onVisibleChanged: if(visible){
									timeline.model.filterText = searchBar.text
									searchBar.forceActiveFocus()
								}else{
									timeline.model.filterText =  ''
								}
			
			TextField {
				id:searchBar
				anchors.fill: parent
				anchors.rightMargin: 7
				anchors.leftMargin: 7
				anchors.topMargin: 5
				anchors.bottomMargin: 5
				width: parent.width - 14				
				icon: text == '' ? 'search_custom' : 'close_custom'
				iconSize: 30
				overwriteColor: TimelineStyle.searchField.color
				//: 'Search in the list' : ths is a placeholder when searching something in the timeline list
				placeholderText: qsTr('timelineSearchPlaceholderText')
				
				onTextChanged: searchDelay.restart()
				font.pointSize: TimelineStyle.searchField.pointSize
				Timer{
					id: searchDelay
					interval: 600
					repeat: false
					onTriggered: timeline.model.filterText = searchBar.text
				}
			}
			
		}
		// -------------------------------------------------------------------------
		// History.
		// -------------------------------------------------------------------------
		
		ScrollableListView {
			id: view
			Layout.fillHeight: true
			Layout.fillWidth: true
			currentIndex: -1
			
			delegate: TimelineItem{
				timelineModel: $modelData
				modelIndex: index
				
				Connections{
					target: $modelData
					onSelectedChanged:{
						if(selected) {
							view.currentIndex = index;
						}
					}
				}
			}
		}
	}
}
