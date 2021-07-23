import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

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
	
	// ---------------------------------------------------------------------------
	/*
  function setSelectedEntry (peerAddress, localAddress) {
	Logic.setSelectedEntry(peerAddress, localAddress)
  }
  
  function resetSelectedEntry () {
	Logic.resetSelectedEntry()
  }
*/
	// ---------------------------------------------------------------------------
	
	color: TimelineStyle.color
	
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		
		// -------------------------------------------------------------------------
		
		Connections {
			target: model
			onSelectedCountChanged:if(selectedCount<=0) view.currentIndex = -1
			// onCurrentTimelineChanged:entrySelected(currentTimeline)
		}
		/*
	Connections {
	  target: model
	  
	  onDataChanged: Logic.handleDataChanged(topLeft, bottomRight, roles)
	  onRowsAboutToBeRemoved: Logic.handleRowsAboutToBeRemoved(parent, first, last)
	}
*/
		// -------------------------------------------------------------------------
		// Legend.
		// -------------------------------------------------------------------------
		
		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: TimelineStyle.legend.height
			Layout.alignment: Qt.AlignTop
			color: showHistory.containsMouse?TimelineStyle.legend.backgroundColor.hovered:TimelineStyle.legend.backgroundColor.normal
			
			MouseArea{
				id:showHistory
				anchors.fill:parent
				onClicked: {
					view.currentIndex = -1
					timeline.entrySelected('',false)
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
					//height: parent.height
					text: 'Filter : All'
					verticalAlignment: Text.AlignVCenter
				}
				
				Icon {
					id:filterButton
					Layout.alignment: Qt.AlignRight
					icon: 'timeline_filter'
					iconSize: TimelineStyle.legend.iconSize
					MouseArea{
						anchors.fill:parent
						onClicked:{
							filterView.visible = !filterView.visible
						}
					}
				}
				
				Icon {
					id:searchButton
					Layout.alignment: Qt.AlignRight
					Layout.rightMargin: TimelineStyle.legend.rightMargin
					icon: (searchView.visible? 'timeline_close': 'timeline_search')
					iconSize: TimelineStyle.legend.iconSize
					MouseArea{
						anchors.fill:parent
						onClicked:{
							searchView.visible = !searchView.visible
						}
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
			border.color: 'black'
			border.width: 2
			visible:false
			
			ColumnLayout{
				id:filterChoices
				anchors.leftMargin: 20
				anchors.left:parent.left
				anchors.right:parent.right
				spacing:-4
				CheckBoxText {
					text:'Appels Simples'
				}
				CheckBoxText {
					text:'Conférences'
				}
				CheckBoxText {
					text:'Messages Simples'
				}
				CheckBoxText {
					text:'Chat de groupe'
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
			border.color: 'black'
			border.width: 2
			visible:false
			//color: ContactsStyle.bar.backgroundColor
		
			  TextField {
				  id:searchBar
				  anchors {
					fill: parent
					margins: 7
				  }
				Layout.fillWidth: true
				icon: 'search'
				placeholderText: 'Search in the list'
				
				onTextChanged: console.log(text)
			  }
			
		}
		// -------------------------------------------------------------------------
		// History.
		// -------------------------------------------------------------------------
		
		ScrollableListView {
			id: view
			Layout.fillHeight: true
			Layout.fillWidth: true
			//anchors.left:parent.left
			//anchors.right:parent.right
			//anchors.bottom:parent.bottom
			currentIndex: -1
			
			delegate: Item {
				height: TimelineStyle.contact.height
				width: parent ? parent.width : 0
				
				Contact {
					property bool isSelected: modelData.selected	//view.currentIndex === index
					
					anchors.fill: parent
					color: isSelected
						   ? TimelineStyle.contact.backgroundColor.selected
						   : (
								 index % 2 == 0
								 ? TimelineStyle.contact.backgroundColor.a
								 : TimelineStyle.contact.backgroundColor.b
								 )
					displayUnreadMessageCount: SettingsModel.chatEnabled
					//entry: $timelineEntry
					//entry: SipAddressesModel.getSipAddressObserver(modelData.fullPeerAddress, modelData.fullLocalAddress)
					entry: modelData.chatRoomModel
					sipAddressColor: isSelected
									 ? TimelineStyle.contact.sipAddress.color.selected
									 : TimelineStyle.contact.sipAddress.color.normal
					usernameColor: isSelected
								   ? TimelineStyle.contact.username.color.selected
								   : TimelineStyle.contact.username.color.normal
					
					Loader {
						anchors.fill: parent
						sourceComponent: TooltipArea {
							
							//text: $timelineEntry.timestamp.toLocaleString(
							//Qt.locale(App.locale),
							//Locale.ShortFormat
							//)
						}
					}
					Icon{
						icon:'timer'
						iconSize: 10
						anchors.right:parent.right
						anchors.bottom:parent.bottom
						anchors.bottomMargin: 5
						anchors.rightMargin: 5
						visible: modelData.chatRoomModel.ephemeralEnabled
					}
				}
				
				MouseArea {
					anchors.fill: parent
					onClicked: {
						//timeline.model.unselectAll()
						modelData.selected = true
						view.currentIndex = index;
						timeline.entrySelected(modelData)
						//timeline.entrySelected($timelineEntry.sipAddress, $timelineEntry.isSecure)
					}
				}
			}
			// onCountChanged: Logic.handleCountChanged(count)
		}
	}
}
