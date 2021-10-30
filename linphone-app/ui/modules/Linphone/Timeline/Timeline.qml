import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import ColorsList 1.0

import UtilsCpp 1.0

import 'Timeline.js' as Logic

// =============================================================================

Rectangle {
	id: timeline
	
	// ---------------------------------------------------------------------------
	
	property alias model: view.model
	property string _selectedSipAddress
	
	// ---------------------------------------------------------------------------
	
	//signal entrySelected (string entry)
	signal entrySelected (TimelineModel entry)
	signal showHistoryRequest()
	
	// ---------------------------------------------------------------------------
	
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
			Layout.fillWidth: true
			Layout.preferredHeight: TimelineStyle.legend.height
			Layout.alignment: Qt.AlignTop
			color: showHistory.containsMouse?TimelineStyle.legend.backgroundColor.hovered:TimelineStyle.legend.backgroundColor.normal
			visible:view.count > 0 || searchView.visible || filterView.visible
			
			MouseArea{// no more showing history
				id:showHistory
				anchors.fill:parent
				onClicked: {
					filterView.visible = !filterView.visible
				}
			}
			RowLayout{
				anchors.fill:parent
				spacing:TimelineStyle.legend.spacing
				Text {
					Layout.preferredHeight: parent.height
					Layout.fillWidth: true
					Layout.leftMargin: TimelineStyle.legend.leftMargin
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
					MouseArea{
						anchors.fill:parent
						onClicked:{
							filterView.visible = !filterView.visible
						}
					}
				}
				MouseArea{
					Layout.alignment: Qt.AlignRight
					Layout.fillHeight: true
					Layout.preferredWidth: TimelineStyle.legend.iconSize
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
			id:filterView
			Layout.fillWidth: true
			Layout.preferredHeight: filterChoices.height
			Layout.alignment: Qt.AlignCenter
			border.color: TimelineStyle.filterField.borderColor
			border.width: 2
			visible:false
			
			ColumnLayout{
				id:filterChoices
				anchors.leftMargin: 20
				anchors.left:parent.left
				anchors.right:parent.right
				spacing:-4
				function getFilterFlags(){
					return simpleFilter.value | secureFilter.value | groupFilter.value | secureGroupFilter.value | ephemeralsFilter.value;
				}
				CheckBoxText {
					id:simpleFilter
					//: 'Simple rooms' : Filter item
					//~ Mode Selecting it will show all simple rooms
					text:qsTr('timelineFilterSimpleRooms')
					property var value : (checkState==Qt.Checked?TimelineProxyModel.SimpleChatRoom: (checkState == Qt.PartiallyChecked ?TimelineProxyModel.NoSimpleChatRoom:0))
					onValueChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					tristate: true
				}
				CheckBoxText {
					id:secureFilter
					//: 'Secure rooms' : Filter item
					//~ Mode Selecting it will show all secure rooms
					text:qsTr('timelineFilterSecureRooms')
					property var value : (checkState==Qt.Checked?TimelineProxyModel.SecureChatRoom: (checkState == Qt.PartiallyChecked ?TimelineProxyModel.NoSecureChatRoom:0))
					onValueChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					tristate: true
				}
				CheckBoxText {
					id:groupFilter
					//: 'Chat groups' : Filter item
					//~ Mode Selecting it will show all chat groups (with more than one participant)
					text:qsTr('timelineFilterChatGroups')
					property var value : (checkState==Qt.Checked?TimelineProxyModel.GroupChatRoom: (checkState == Qt.PartiallyChecked ?TimelineProxyModel.NoGroupChatRoom:0))
					onValueChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					tristate: true
				}
				CheckBoxText {
					id:secureGroupFilter
					//: 'Secure Chat Groups' : Filter item
					//~ Mode Selecting it will show all secure chat groups (with more than one participant)
					text:qsTr('timelineFilterSecureChatGroups')
					property var value : (checkState==Qt.Checked?TimelineProxyModel.SecureGroupChatRoom: (checkState == Qt.PartiallyChecked ?TimelineProxyModel.NoSecureGroupChatRoom:0))
					onValueChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					tristate: true
				}
				CheckBoxText {
					id:ephemeralsFilter
					//: 'Ephemerals' : Filter item
					//~ Mode Selecting it will show all chat rooms where the ephemeral mode has been enabled.
					text:qsTr('timelineFilterEphemerals')
					property var value : (checkState==Qt.Checked?TimelineProxyModel.EphemeralChatRoom: (checkState == Qt.PartiallyChecked ?TimelineProxyModel.NoEphemeralChatRoom:0))
					onValueChanged: timeline.model.filterFlags = filterChoices.getFilterFlags()
					tristate: true
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
				anchors {
					fill: parent
					margins: 7
				}
				width: parent.width - 14
				icon: 'search_custom'
				iconSize: 30
				overwriteColor: TimelineStyle.searchField.color
				//: 'Search in the list' : ths is a placeholder when searching something in the timeline list
				placeholderText: qsTr('timelineSearchPlaceholderText')
				
				onTextChanged: timeline.model.filterText = text
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
			
			delegate: Item {
				height: TimelineStyle.contact.height
				width: parent ? parent.width : 0
				
				Contact {
					id: contactView
					property bool isSelected: modelData != undefined && modelData.selected	//view.currentIndex === index
					
					anchors.fill: parent
					color: isSelected
						   ? TimelineStyle.contact.backgroundColor.selected
						   : (
								 index % 2 == 0
								 ? TimelineStyle.contact.backgroundColor.a
								 : TimelineStyle.contact.backgroundColor.b
								 )
					displayUnreadMessageCount: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
					entry: modelData.chatRoomModel
					sipAddressColor: isSelected
									 ? TimelineStyle.contact.sipAddress.color.selected
									 : TimelineStyle.contact.sipAddress.color.normal
					usernameColor: isSelected
								   ? TimelineStyle.contact.username.color.selected
								   : TimelineStyle.contact.username.color.normal
					TooltipArea {	
						id: contactTooltip						
						text: UtilsCpp.toDateTimeString(modelData.chatRoomModel.lastUpdateTime)
						isClickable: true
					}
					Icon{
						icon: TimelineStyle.ephemeralTimer.icon
						iconSize: TimelineStyle.ephemeralTimer.iconSize
						overwriteColor:  modelData && modelData.selected ? TimelineStyle.ephemeralTimer.selectedTimerColor : TimelineStyle.ephemeralTimer.timerColor
						anchors.right:parent.right
						anchors.bottom:parent.bottom
						anchors.bottomMargin: 7
						anchors.rightMargin: 7
						visible: modelData.chatRoomModel.ephemeralEnabled
					}
				}
				
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					propagateComposedEvents: true
					preventStealing: false
					onClicked: {
						//timeline.model.unselectAll()
						if(mouse.button == Qt.LeftButton){
							if(modelData.selected)// Update selection
								timeline.entrySelected(modelData)
							modelData.selected = true
							view.currentIndex = index;
						}else{
							contactTooltip.show()
						}
					}
				}
				
				Connections{
					target:modelData
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
