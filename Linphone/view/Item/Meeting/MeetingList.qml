import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Effects

import Linphone
import QtQml
import UtilsCpp 1.0

ListView {
	id: mainItem
	visible: count > 0
	clip: true

	property string searchBarText

	property bool hoverEnabled: true
	
	property int delegateLeftMargin: 0
	currentIndex: -1

	property var delegateButtons

	property ConferenceInfoGui selectedConference: model.getAt(currentIndex) || null

	onCountChanged: selectedConference = model.getAt(currentIndex) || null
	onCurrentIndexChanged: selectedConference = model.getAt(currentIndex) || null

	signal conferenceSelected(var contact)

	model: ConferenceInfoProxy {
		searchText: searchBarText.length === 0 ? "" : searchBarText
	}

	section {
		criteria: ViewSection.FullString
		delegate: Text {
			text: section
			height: 29 * DefaultStyle.dp
			font {
				pixelSize: 20 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
				capitalization: Font.Capitalize
			}
		}
		property: '$sectionMonth'
	}

	delegate: Item {
		id: itemDelegate
		height: 80 * DefaultStyle.dp
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDateTime: previousItem ? previousItem.core.dateTimeUtc : null
		property var dateTime: $modelData.core.dateTime
		property var endDateTime: $modelData.core.endDateTime
		ColumnLayout {
			id: dateDay
			width: 32 * DefaultStyle.dp
			height: 51 * DefaultStyle.dp
			visible: !previousDateTime || previousDateTime != dateTime
			anchors.verticalCenter: parent.verticalCenter
			Text {
				verticalAlignment: Text.AlignVCenter
				Layout.preferredWidth: 32 * DefaultStyle.dp
				Layout.preferredHeight: 19 * DefaultStyle.dp
				// opacity: (!previousItem || !previousDateTime.startsWith(displayName[0])) ? 1 : 0
				text: UtilsCpp.toDateDayNameString(dateTime)
				color: DefaultStyle.main2_500main
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
					capitalization: Font.Capitalize
				}
			}
			Rectangle {
				id: dayNum
				Layout.preferredWidth: 32 * DefaultStyle.dp
				Layout.preferredHeight: 32 * DefaultStyle.dp
				radius: 50 * DefaultStyle.dp
				property var isCurrentDay: UtilsCpp.isCurrentDay(dateTime)
				color: isCurrentDay ? DefaultStyle.main1_500_main : "transparent"
				Component.onCompleted: if(isCurrentDay) mainItem.currentIndex = index
				Text {
					anchors.centerIn: parent
					text: UtilsCpp.toDateDayString(dateTime)
					color: dayNum.isCurrentDay ? DefaultStyle.grey_0 : DefaultStyle.main2_500main
					font {
						pixelSize: 20 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
			}
		}
		Rectangle {
			id: conferenceInfoDelegate
			anchors.left: dateDay.visible ? dateDay.right : parent.left
			anchors.leftMargin: 10 * DefaultStyle.dp + mainItem.delegateLeftMargin
			anchors.rightMargin: 25 * DefaultStyle.dp + mainItem.delegateLeftMargin
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			radius: 10 * DefaultStyle.dp
			// width: 265 * DefaultStyle.dp
			height: 63 * DefaultStyle.dp
			color: mainItem.currentIndex === index ? DefaultStyle.main2_200 : DefaultStyle.grey_0
			ColumnLayout {
				anchors.fill: parent
				anchors.left: parent.left
				anchors.leftMargin: 15 * DefaultStyle.dp
				spacing: 2 * DefaultStyle.dp
				RowLayout {
					spacing: 8 * DefaultStyle.dp
					Image {
						source: AppIcons.usersThree
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
					}
					Text {
						text: $modelData.core.subject
						font {
							pixelSize: 13 * DefaultStyle.dp
							weight: 700 * DefaultStyle.dp
						}
					}
				}
				Text {
					text: UtilsCpp.toDateHourString(dateTime) + " - " + UtilsCpp.toDateHourString(endDateTime)
					color: DefaultStyle.main2_500main
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
					}
				}
			}
		}

		MultiEffect {
			source: conferenceInfoDelegate
			anchors.fill: conferenceInfoDelegate
			shadowEnabled: true
			shadowBlur: 1.0
			shadowOpacity: 0.1
		}
		
		MouseArea {
			id: confArea
			hoverEnabled: mainItem.hoverEnabled
			anchors.fill: dateDay.visible ? conferenceInfoDelegate : parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				mainItem.currentIndex = index
				mainItem.conferenceSelected($modelData)
			}
		}
	}
}
