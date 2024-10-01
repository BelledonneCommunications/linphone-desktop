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
	property ConferenceInfoGui selectedConference: model && currentIndex != -1 ? model.getAt(currentIndex) : null
	
	spacing: 8 * DefaultStyle.dp
	currentIndex: confInfoProxy.currentDateIndex

	onCountChanged: selectedConference = model && currentIndex != -1 && currentIndex < model.count ? model.getAt(currentIndex) : null
	onCurrentIndexChanged: {
		selectedConference = model.getAt(currentIndex) || null
	}
	onVisibleChanged: if( visible) {
		mainItem.positionViewAtIndex(currentIndex, ListView.Center)// First approximative move
		delayMove.restart()	// Move to exact position after load.
	}
	Timer{
		id: delayMove
		interval: 60
		onTriggered: mainItem.positionViewAtIndex(currentIndex, ListView.Center)
	}
	// using highlight doesn't center, take time before moving and don't work for not visible item (like not loaded)
	highlightFollowsCurrentItem: false

	signal conferenceSelected(var contact)

	model: ConferenceInfoProxy {
		id: confInfoProxy
		searchText: searchBarText
		filterType: ConferenceInfoProxy.None
	}

	section {
		criteria: ViewSection.FullString
		delegate: Text {
			topPadding: 24 * DefaultStyle.dp
			bottomPadding: 16 * DefaultStyle.dp
			text: section
			height: 29 * DefaultStyle.dp + topPadding + bottomPadding
			wrapMode: Text.NoWrap
			font {
				pixelSize: 20 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
				capitalization: Font.Capitalize
			}
		}
		property: '$sectionMonth'
	}

	delegate: FocusScope {
		id: itemDelegate
		height: 63 * DefaultStyle.dp + topOffset
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var dateTime: !!$modelData && $modelData.core.haveModel ? $modelData.core.dateTime : UtilsCpp.getCurrentDateTime()
		property string day : UtilsCpp.toDateDayNameString(dateTime)
		property string dateString:  UtilsCpp.toDateString(dateTime)
		property string previousDateString: previousItem ? UtilsCpp.toDateString(previousItem.core ? previousItem.core.dateTimeUtc : UtilsCpp.getCurrentDateTimeUtc()) : ''
		property bool isFirst : ListView.previousSection !== ListView.section
		property int topOffset: (dateDay.visible && !isFirst? 8 * DefaultStyle.dp : 0)
		property var endDateTime: $modelData ? $modelData.core.endDateTime : UtilsCpp.getCurrentDateTime()
				
		property var haveModel: $modelData && $modelData.core.haveModel || false
		
		
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
				Layout.preferredHeight: 51 * DefaultStyle.dp
				visible: previousDateString.length == 0 || previousDateString != dateString
				spacing: 0
				Text {
					Layout.preferredHeight: 19 * DefaultStyle.dp
					Layout.alignment: Qt.AlignCenter
					text: day.substring(0,3) + '.'
					color: DefaultStyle.main2_500main
					wrapMode: Text.NoWrap
					elide: Text.ElideNone
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
					Layout.alignment: Qt.AlignCenter
					radius: height/2
					property var isCurrentDay: UtilsCpp.isCurrentDay(dateTime)

					color: isCurrentDay ? DefaultStyle.main1_500_main : "transparent"
					
					Text {
						anchors.centerIn: parent
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignHCenter
						text: UtilsCpp.toDateDayString(dateTime)
						color: dayNum.isCurrentDay ? DefaultStyle.grey_0 : DefaultStyle.main2_500main
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
					visible: itemDelegate.haveModel || itemDelegate.activeFocus
					color: mainItem.currentIndex === index ? DefaultStyle.main2_200 : DefaultStyle.grey_0
					ColumnLayout {
						anchors.fill: parent
						anchors.left: parent.left
						anchors.leftMargin: 15 * DefaultStyle.dp
						spacing: 2 * DefaultStyle.dp
						visible: itemDelegate.haveModel
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
					visible: itemDelegate.haveModel
					shadowEnabled: true
					shadowBlur: 0.7
					shadowOpacity: 0.2
				}
				Text {
					anchors.fill: parent
					anchors.rightMargin: 5 * DefaultStyle.dp // margin to avoid clipping shadows at right
					anchors.leftMargin: 16 * DefaultStyle.dp
					verticalAlignment: Text.AlignVCenter
					visible: !itemDelegate.haveModel
					text: qsTr("Aucune réunion aujourd'hui")
					lineHeightMode: Text.FixedHeight
					lineHeight: 17.71 * DefaultStyle.dp
					font {
						pixelSize: 13 * DefaultStyle.dp
						weight: 700
					}
				}
				MouseArea {
					hoverEnabled: mainItem.hoverEnabled
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					visible: itemDelegate.haveModel
					onClicked: {
						mainItem.currentIndex = index
						mainItem.conferenceSelected($modelData)
						itemDelegate.forceActiveFocus()
					}
				}
			}
		}

		// MouseArea {
		// 	id: confArea
		// 	hoverEnabled: mainItem.hoverEnabled
		// 	visible: !dateDay.visible && itemDelegate.haveModel
		// 	anchors.fill: parent
		// 	cursorShape: Qt.PointingHandCursor
		// 	onClicked: {
		// 		mainItem.currentIndex = index
		// 		mainItem.conferenceSelected($modelData)
		// 	}
		// }
	}
}
