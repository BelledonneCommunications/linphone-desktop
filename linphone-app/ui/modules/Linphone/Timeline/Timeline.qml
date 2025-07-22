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
	property bool optionsTogglable: true
	property var actions: []
	// ---------------------------------------------------------------------------
	
	signal entrySelected (var entry)
	signal showHistoryRequest()
	
	// ---------------------------------------------------------------------------
	property bool showFilterView : false
	color: TimelineStyle.colorModel.color
	
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
			Layout.preferredWidth: timeline.width
			Layout.preferredHeight: 50
			Layout.alignment: Qt.AlignTop
			color: TimelineStyle.legend.backgroundColor.normal.color
			RowLayout{
				anchors.fill: parent
				Text {
					Layout.preferredHeight: parent.height
					Layout.fillWidth: true
					Layout.leftMargin: 10
					color: TimelineStyle.legend.colorModel.color
					font.pointSize: TimelineStyle.legend.pointSize
					font.weight: Font.Bold
					font.capitalization: Font.Capitalize
					//: 'Messages' : Title for conversations
					text: qsTr('chatsTitle').toLowerCase()
					verticalAlignment: Text.AlignVCenter
				}
				
				ActionButton {
					id:filterButton
					Layout.alignment: Qt.AlignRight
					isCustom: true
					colorSet: TimelineStyle.filterAction
					toggled: view.model.filterFlags != 0 && view.model.filterFlags != TimelineProxyModel.AllChatRooms
					onClicked: filterMenu.open()
					Menu{
						id: filterMenu
						MenuItem{
							id: secureFilter
							//: 'Secure rooms' : Filter item. Selecting it will show all secure rooms.
							text: qsTr('timelineFilterSecureRooms')
							checkable: true
						}
						MenuItem{
							id: chatGroupFilter
							//: 'Chat groups' : Filter item. Selecting it will show all chat groups (with more than one participant).
							text: qsTr('timelineFilterChatGroups')
							checkable: true
						}
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
			Layout.preferredHeight: 50
			Layout.alignment: Qt.AlignCenter
			color: legendArea.color
			TextField {
				id:searchBar
				anchors.fill: parent
				anchors.rightMargin: 10
				anchors.leftMargin: 10
				anchors.topMargin: 5
				anchors.bottomMargin: 10
				width: parent.width - 14				
				icon: text == '' ? 'search_custom' : 'close_custom'
				iconSize: 30
				overwriteColor: TimelineStyle.searchField.colorModel.color
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
			model: TimelineProxyModel{
					listSource: TimelineProxyModel.Main
					filterFlags: (secureFilter.checked ? TimelineProxyModel.SecureChatRoom : 0)
							| (chatGroupFilter.checked ? TimelineProxyModel.GroupChatRoom : 0)
			}
			delegate: Loader{
				width: view.contentWidth
				asynchronous: index > 20
				active: true
				sourceComponent: TimelineItem{
					timelineModel: !!$modelData ? $modelData : null
					modelIndex: index
					optionsTogglable: timeline.optionsTogglable
					actions: timeline.actions
										
					Connections{
						target: !!$modelData ? $modelData : null
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
}
