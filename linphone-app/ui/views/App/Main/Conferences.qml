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
	id: container
	property int filterMode: ConferenceInfoProxyModel.ConferenceType.Scheduled
	spacing: 0
	
	// ---------------------------------------------------------------------------
	// Title
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ConferencesStyle.bar.height
		
		color: ConferencesStyle.bar.backgroundColor
		Text{
			anchors.verticalCenter: parent.center
			anchors.fill: parent
			verticalAlignment: Qt.AlignCenter
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
				
				onClicked: {
					mainItem.filterMode = (button === 0 ? ConferenceInfoProxyModel.ConferenceType.Ended : button === 1 ?ConferenceInfoProxyModel.ConferenceType.Scheduled : ConferenceInfoProxyModel.ConferenceType.Invitations);
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
				property: 'date'
			}
			
			model: ConferenceInfoProxyModel{
				id: conferencesProxyModel
				
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
					//anchors.fill: parent
					cellWidth: (container.width-20)/2
					cellHeight: 100
					model: $modelData
					height: cellHeight * ( (count+1) /2)
					width: container.width - 20
					delegate:Rectangle {
						id: entry
						width: calendarGrid.cellWidth -10
						height: calendarGrid.cellHeight -10
						radius: 6
						color: ConferencesStyle.conference.backgroundColor.normal
						border.color: calendarMessage.containsMouse ? ConferencesStyle.conference.selectedBorder.color  : 'transparent'
						border.width: ConferencesStyle.conference.selectedBorder.width
						ChatCalendarMessage{
							id: calendarMessage
							conferenceInfoModel: $modelData
							width: calendarGrid.cellWidth
							maxWidth: calendarGrid.cellWidth
						}
					}
				}
			}
			
		}
	}
}
