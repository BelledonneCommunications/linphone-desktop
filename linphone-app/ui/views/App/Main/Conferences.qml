import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
	id: mainItem
	property int filterType: -1
	spacing: 0
	Component.onCompleted: filterType = ConferenceInfoProxyModel.Scheduled
	// ---------------------------------------------------------------------------
	// Title
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ConferencesStyle.bar.height
		
		color: ConferencesStyle.bar.backgroundColor
		Text{
			anchors.fill: parent
			verticalAlignment: Qt.AlignVCenter
			
			anchors.leftMargin: 40
			
			text: 'Mes conférences'
		}
	}
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ConferencesStyle.bar.height
		
		color: 'white'
		
		RowLayout {
			anchors {
				fill: parent
				leftMargin: ConferencesStyle.bar.leftMargin
				rightMargin: ConferencesStyle.bar.rightMargin
			}
			spacing: ConferencesStyle.spacing
			
			ExclusiveButtons {
				texts: [
					'TERMINEES',
					'PROGRAMMEES',
					'INVITATIONS'
				]
				selectedButton: mainItem.filterType
				onClicked: {
					mainItem.filterType = (button === 0 ? ConferenceInfoProxyModel.Ended : button === 1 ?ConferenceInfoProxyModel.Scheduled : ConferenceInfoProxyModel.Invitations);
					//mainItem.filterType = button
				}
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Conferences list.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.fillHeight: true
		color: ConferencesStyle.backgroundColor
		
		ScrollableListView {
			anchors.fill: parent
			spacing: 10
			
			highlightFollowsCurrentItem: false
			
			section {
				criteria: ViewSection.FullString
				delegate: sectionHeading
				property: '$modelKey'
			}
			
			model: ConferenceInfoProxyModel{
				id: conferencesProxyModel
				filterType: mainItem.filterType
			}
			
			// -----------------------------------------------------------------------
			// Heading.
			// -----------------------------------------------------------------------
			
			Component {
				id: sectionHeading
				
				Item {
					implicitHeight: container.height + ConferencesStyle.sectionHeading.bottomMargin
					width: parent.width
					
					Borders {
						id: container
						
						borderColor: ConferencesStyle.sectionHeading.border.color
						bottomWidth: ConferencesStyle.sectionHeading.border.width
						implicitHeight: text.contentHeight +
										ConferencesStyle.sectionHeading.padding * 2 +
										ConferencesStyle.sectionHeading.border.width * 2
						topWidth: ConferencesStyle.sectionHeading.border.width
						width: parent.width
						
						Text {
							id: text
							
							anchors.fill: parent
							color: ConferencesStyle.sectionHeading.text.color
							font {
								bold: true
								pointSize: ConferencesStyle.sectionHeading.text.pointSize
							}
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							
							// Cast section to integer because Qt converts the
							// sectionDate in string!!!
							text: new Date(section).toLocaleDateString(
									  Qt.locale(App.locale)
									  )
						}
					}
				}
			}
			
			//----------------------------------------------------------------------------------------------
			//----------------------------------------------------------------------------------------------
			//----------------------------------------------------------------------------------------------
			
			delegate: Item {
				implicitHeight: calendarGrid.height + ConferencesStyle.conference.bottomMargin
				anchors {
							left: parent ? parent.left : undefined
							leftMargin: 10
							right: parent ? parent.right : undefined
							rightMargin: 10
						}
				GridView{
					id: calendarGrid
					property bool expanded : false					//anchors.fill: parent
					cellWidth: width/2
					cellHeight: expanded ? 300 : 100
					model: $modelData
					height: cellHeight * ( (count+1) /2)
					width: mainItem.width - 20
					delegate:Rectangle {
						id: entry
						
						width: calendarGrid.cellWidth-10
						height: calendarGrid.cellHeight-10
						radius: 6
						color: mainItem.filterType == ConferenceInfoProxyModel.Ended ? ConferencesStyle.conference.backgroundColor.ended
								: ConferencesStyle.conference.backgroundColor.scheduled
						border.color: calendarMessage.containsMouse || calendarMessage.isExpanded ? ConferencesStyle.conference.selectedBorder.color  : 'transparent'
						border.width: ConferencesStyle.conference.selectedBorder.width
						ChatCalendarMessage{
							id: calendarMessage
							anchors.centerIn: parent
							width: parent.width
							height: parent.height
							conferenceInfoModel: $modelData
							//width: calendarGrid.cellWidth
							//maxWidth: calendarGrid.cellWidth
							gotoButtonMode: mainItem.filterType == ConferenceInfoProxyModel.Scheduled ? 1 
													: mainItem.filterType == ConferenceInfoProxyModel.Ended ? -1
														: 0
							onExpandToggle: calendarGrid.expanded = !calendarGrid.expanded
							isExpanded: calendarGrid.expanded
						}
					}
				}
			}
			
		}
	}
}
