import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
Item{
	
	ColumnLayout {
		id: mainItem
		property int filterType: -1
		spacing: 0
		onFilterTypeChanged: Qt.callLater( conferenceList.positionViewAtEnd)
		Component.onCompleted: filterType = ConferenceInfoProxyModel.Scheduled
		anchors.fill: parent
		// ---------------------------------------------------------------------------
		// Title
		// ---------------------------------------------------------------------------
		
		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: ConferencesStyle.bar.height
			
			color: ConferencesStyle.bar.backgroundColor.color
			Text{
				anchors.fill: parent
				verticalAlignment: Qt.AlignVCenter
				
				anchors.leftMargin: 40
				
				color: ConferencesStyle.bar.text.colorModel.color
				font {
					bold: true
					pointSize: ConferencesStyle.bar.text.pointSize
				}
				//: 'Meetings' : Conference list title.
				text: qsTr('conferencesTitle')
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
						//: 'Finished' : Filter meetings on end status.
						qsTr('conferencesEndedFilter'),
						
						//: 'Scheduled' : Filter meetings on scheduled status.
						qsTr('conferencesScheduledFilter'),
					]
					capitalization: Font.AllUppercase
					selectedButton: mainItem.filterType
					style: ConferencesStyle.filter.buttons
					onClicked: {
						if(button <= 1)
							mainItem.filterType = (button === 0 ? ConferenceInfoProxyModel.Ended :  ConferenceInfoProxyModel.Scheduled);
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
			color: ConferencesStyle.backgroundColor.color
			
			ScrollableListView {
				id: conferenceList
				anchors.fill: parent
				spacing: 10
				
				highlightFollowsCurrentItem: false
				fitCacheToContent: false
				
				section {
					criteria: ViewSection.FullString
					delegate: sectionHeading
					property: '$sectionDate'
				}
				
				model: ConferenceInfoProxyModel{
					id: conferencesProxyModel
					filterType: mainItem.filterType
					onFilterTypeChanged: setSortOrder(filterType == ConferenceInfoProxyModel.Ended ? Qt.AscendingOrder : Qt.DescendingOrder)
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
							
							borderColor: ConferencesStyle.sectionHeading.border.colorModel.color
							bottomWidth: ConferencesStyle.sectionHeading.border.width
							implicitHeight: text.contentHeight +
											ConferencesStyle.sectionHeading.padding * 2 +
											ConferencesStyle.sectionHeading.border.width * 2
							topWidth: ConferencesStyle.sectionHeading.border.width
							width: parent.width
							
							Text {
								id: text
								
								anchors.fill: parent
								color: ConferencesStyle.sectionHeading.text.colorModel.color
								font {
									bold: true
									pointSize: ConferencesStyle.sectionHeading.text.pointSize
								}
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
								
								text: UtilsCpp.toDateString(section)
							}
						}
					}
				}
				
				//----------------------------------------------------------------------------------------------
				//----------------------------------------------------------------------------------------------
				//----------------------------------------------------------------------------------------------
				
				delegate: Item {
					height: entry.height + ConferencesStyle.conference.bottomMargin
					anchors {
						left: parent ? parent.left : undefined
						leftMargin: 10
						right: parent ? parent.right : undefined
						rightMargin: 10
					}
					Rectangle {
						id: entry
						anchors.centerIn: parent
						width: parent.width / 2
						height: calendarMessage.height
						radius: 6
						color: calendarMessage.isCancelled
									? ConferencesStyle.conference.backgroundColor.cancelled.color
									: mainItem.filterType == ConferenceInfoProxyModel.Ended
										? ConferencesStyle.conference.backgroundColor.ended.color
										: ConferencesStyle.conference.backgroundColor.scheduled.color
						border.color: calendarMessage.containsMouse || calendarMessage.isExpanded ? ConferencesStyle.conference.selectedBorder.colorModel.color  : 'transparent'
						border.width: ConferencesStyle.conference.selectedBorder.width
						ChatCalendarMessage{
							id: calendarMessage
							anchors.centerIn: parent
							width: parent.width
							height: fitHeight
							conferenceInfoModel: $modelData
							gotoButtonMode: mainItem.filterType == ConferenceInfoProxyModel.Scheduled || mainItem.filterType == ConferenceInfoProxyModel.Ended? 1
																																							  : 0
							onExpandToggle: isExpanded = !isExpanded
							//isExpanded: calendarGrid.expanded
							//: 'The meeting URL has been copied' : Message text in a banner to warn the user that the URL have been copied to the clipboard.
							onConferenceUriCopied: messageBanner.noticeBannerText = qsTr('conferencesCopiedURL')
							//: 'The meeting has been deleted' : Message text in a banner to warn the user that the meeting has been deleted.
							onConferenceRemoved: messageBanner.noticeBannerText = qsTr('conferencesDeleted')
						}
					}
				}
			}
		}
	}
	MessageBanner{
		id: messageBanner
		
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 25
		
		height: fitHeight
	}
}
