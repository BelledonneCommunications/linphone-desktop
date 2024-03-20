import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Shapes 1.10


import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import ColorsList 1.0

import UtilsCpp 1.0

import 'Timeline.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
ColumnLayout{
	id: mainItem
	signal entrySelected(var model)
	
	Layout.fillHeight: true
	spacing: 0
// HEADER
	Rectangle {
		id: legendArea
		Layout.preferredWidth: mainItem.width
		Layout.preferredHeight: 50
		Layout.alignment: Qt.AlignTop
		color: CallTimelineStyle.backgroundColor.normal.color
		RowLayout{
			anchors.fill: parent
			spacing: 2
			Text {
				Layout.preferredHeight: parent.height
				Layout.fillWidth: true
				Layout.leftMargin: 10
				color: CallTimelineStyle.colorModel.color
				font.pointSize: CallTimelineStyle.pointSize
				font.weight: Font.Bold
				font.capitalization: Font.Capitalize
				//: 'Call list' : Call histories title
				text: qsTr('callListTitle').toLowerCase()
				verticalAlignment: Text.AlignVCenter
			}
			
			ActionButton {
				id:filterButton
				Layout.alignment: Qt.AlignRight
				isCustom: true
				colorSet: CallTimelineStyle.filterAction
				toggled: view.model.filterFlags != 0 && view.model.filterFlags != CallHistoryProxyModel.All
				
				onClicked: filterMenu.open()
				Menu{
					id: filterMenu
					MenuItem{
						id: incomingFilter
						//: 'Incoming' : Filter label for incoming call
						text: qsTr('incomingFilter')
						checkable: true
					}
					MenuItem{
						id: outgoingFilter
						//: 'Outgoing' : Filter label for outgoing call
						text: qsTr('outgoingFilter')
						checkable: true
					}
					MenuItem{
						id: missedFilter
						//: 'Missed' : Filter label for missed call
						text: qsTr('missedFilter')
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
		Layout.preferredWidth: mainItem.width
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
			overwriteColor: CallTimelineStyle.searchField.colorModel.color
			//: 'Search in the list' : ths is a placeholder when searching something in a list
			placeholderText: qsTr('searchListPlaceholderText')
			
			onTextChanged: searchDelay.restart()
			font.pointSize: CallTimelineStyle.searchField.pointSize
			Timer{
				id: searchDelay
				interval: 600
				repeat: false
				onTriggered: view.model.filterText = searchBar.text
			}
		}
	}
	
	ScrollableListView {
		id: view
		Layout.fillHeight: true
		Layout.preferredWidth: mainItem.width
		currentIndex: -1
		
		model: CallHistoryProxyModel{
			filterFlags: (incomingFilter.checked ? CallHistoryProxyModel.Incoming : 0)
							| (outgoingFilter.checked ? CallHistoryProxyModel.Outgoing : 0)
							| (missedFilter.checked ? CallHistoryProxyModel.Missed : 0)
		}
		onCountChanged: if(count == 0) mainItem.entrySelected(null)
		delegate: Loader{
			property CallHistoryModel historyModel: $modelData// use loader property to avoid desync variables into Component.
			width: view.contentWidth
			asynchronous: index > 20
			active: historyModel
			sourceComponent: CallTimelineItem{
				callHistoryModel: historyModel
				modelIndex: index
				Connections{
					target: historyModel
					onSelectedChanged:{
						if(selected) {
							view.currentIndex = index;
							mainItem.entrySelected(model)
						}
					}
				}
			}
		}
	}
}
