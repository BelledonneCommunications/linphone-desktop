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
	property var delegateButtons
	property ConferenceInfoGui selectedConference: model.getAt(currentIndex) || null

	spacing: 8 * DefaultStyle.dp
	currentIndex: -1

	onCountChanged: selectedConference = model.getAt(currentIndex) || null
	onCurrentIndexChanged: selectedConference = model.getAt(currentIndex) || null

	function forceUpdate() {
		confInfoProxy.lUpdate()
	}

	signal conferenceSelected(var contact)

	model: ConferenceInfoProxy {
		id: confInfoProxy
		searchText: searchBarText.length === 0 ? "" : searchBarText
	}

	section {
		criteria: ViewSection.FullString
		delegate: Text {
			topPadding: 24 * DefaultStyle.dp
			bottomPadding: 16 * DefaultStyle.dp
			text: section
			height: 29 * DefaultStyle.dp + topPadding + bottomPadding
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
		height: 63 * DefaultStyle.dp + topOffset
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var dateTime: $modelData.core.dateTime
		property string day : UtilsCpp.toDateDayNameString(dateTime)
		property string dateString:  UtilsCpp.toDateString(dateTime)
		property string previousDateString: previousItem ? UtilsCpp.toDateString(previousItem.core.dateTimeUtc) : ''
		property bool isFirst : ListView.previousSection !== ListView.section
		property int topOffset: (dateDay.visible && !isFirst? 8 * DefaultStyle.dp : 0)


		property var endDateTime: $modelData.core.endDateTime
		RowLayout{
			anchors.fill: parent
			anchors.topMargin:parent.topOffset
			spacing: 0
			Item{
				Layout.preferredWidth: 32 * DefaultStyle.dp
				visible: !dateDay.visible
			}
			ColumnLayout {
				id: dateDay
				Layout.fillWidth: false
				Layout.preferredWidth: 32 * DefaultStyle.dp
				Layout.minimumWidth: 32 * DefaultStyle.dp
				height: 51 * DefaultStyle.dp
				visible: !previousDateString || previousDateString != dateString
				spacing: 0
				//anchors.leftMargin: 45 * DefaultStyle.dp
				Text {
					//Layout.preferredWidth: 32 * DefaultStyle.dp
					Layout.preferredHeight: 19 * DefaultStyle.dp
					Layout.fillWidth: true
					// opacity: (!previousItem || !previousDateTime.startsWith(displayName[0])) ? 1 : 0
					text: day
					color: DefaultStyle.main2_500main
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
						capitalization: Font.Capitalize
					}
				}
				Rectangle {
					id: dayNum
					//Layout.preferredWidth: Math.max(32 * DefaultStyle.dp, dayNumText.width+17*DefaultStyle.dp)
					Layout.fillWidth: true
					Layout.preferredHeight: width
					Layout.alignment: Qt.AlignCenter
					radius: height/2
					property var isCurrentDay: UtilsCpp.isCurrentDay(dateTime)

					color: !isCurrentDay ? DefaultStyle.main1_500_main : "transparent"
					Component.onCompleted: if(isCurrentDay) mainItem.currentIndex = index
					Text {
						id: dayNumText
						anchors.centerIn: parent
						verticalAlignment: Text.AlignVCenter
						text: UtilsCpp.toDateDayString(dateTime)
						color: !dayNum.isCurrentDay ? DefaultStyle.grey_0 : DefaultStyle.main2_500main
						wrapMode: Text.NoWrap
						font {
							pixelSize: 20 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
				}
				Item{Layout.fillHeight:true;Layout.fillWidth: true}
			}
			Item {
				Layout.preferredWidth: 265 * DefaultStyle.dp
				Layout.preferredHeight: 63 * DefaultStyle.dp
				Layout.leftMargin: 23 * DefaultStyle.dp
				Rectangle {
					id: conferenceInfoDelegate
					anchors.fill: parent
					anchors.rightMargin: 5	// margin to avoid clipping shadows at right
					radius: 10 * DefaultStyle.dp

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
					shadowBlur: 0.7
					shadowOpacity: 0.2
				}
				MouseArea {
					hoverEnabled: mainItem.hoverEnabled
					anchors.fill: parent
					visible: dateDay.visible
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						mainItem.currentIndex = index
						mainItem.conferenceSelected($modelData)
					}
				}
			}
		}


		
		MouseArea {
			id: confArea
			hoverEnabled: mainItem.hoverEnabled
			visible: !dateDay.visible
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				mainItem.currentIndex = index
				mainItem.conferenceSelected($modelData)
			}
		}
	}
}
