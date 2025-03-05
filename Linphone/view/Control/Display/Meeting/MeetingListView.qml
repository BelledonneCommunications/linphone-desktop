import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic

import Linphone
import QtQml
import UtilsCpp

import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

ListView {
	id: mainItem
	property string searchBarText
	property bool hoverEnabled: true	
	property var delegateButtons
	property ConferenceInfoGui selectedConference
	property bool _moveToIndex: false

	visible: count > 0
	clip: true
	cacheBuffer: height/2
	
    spacing: Math.round(8 * DefaultStyle.dp)
	highlightFollowsCurrentItem: false
	
	function selectIndex(index){
		mainItem.currentIndex = index
	}
		
	function resetSelections(){
		mainItem.selectedConference = null
		mainItem.currentIndex = -1
	}
	
//----------------------------------------------------------------	
	function moveToCurrentItem(){
		if( mainItem.currentIndex >= 0)
			Utils.updatePosition(mainItem, mainItem)
	}
	onCurrentItemChanged: {
		moveToCurrentItem()
		if(currentItem) {
			mainItem.selectedConference = currentItem.itemGui
			currentItem.forceActiveFocus()
		}
	}
	// Update position only if we are moving to current item and its position is changing.
	property var _currentItemY: currentItem?.y
	on_CurrentItemYChanged: if(_currentItemY && moveAnimation.running){
		moveToCurrentItem()
	}
	Behavior on contentY{
		NumberAnimation {
			id: moveAnimation
			duration: 500
			easing.type: Easing.OutExpo
			alwaysRunToEnd: true
		}
	}
//----------------------------------------------------------------
	onAtYEndChanged: if(atYEnd) confInfoProxy.displayMore()
	
	
	Keys.onPressed: (event)=> {
		if(event.key == Qt.Key_Up) {
			if(currentIndex > 0 ) {
				selectIndex(mainItem.currentIndex-1)
				event.accepted = true
			} else {
				selectIndex(model.count - 1)
				event.accepted = true
			}
		}else if(event.key == Qt.Key_Down){
			if(currentIndex < model.count - 1) {
				selectIndex(currentIndex+1)
				event.accepted = true
			} else {
				selectIndex(0)
				event.accepted = true
			}
		}
	}
	
	model: ConferenceInfoProxy {
		id: confInfoProxy
		filterText: searchBarText
		filterType: ConferenceInfoProxy.None
        initialDisplayItems: Math.max(20, 2 * mainItem.height / (Math.round(63 * DefaultStyle.dp)))
		displayItemsStep: initialDisplayItems/2
		function selectData(confInfoGui){
			mainItem.currentIndex = loadUntil(confInfoGui)
		}
		onConferenceInfoCreated: (confInfoGui) => {
			selectData(confInfoGui)
		}
		onConferenceInfoUpdated: (confInfoGui) => {
			selectData(confInfoGui)
		}
		onInitialized: {
			// Move to currentDate
			selectData(null)
		}
	}
	
	ScrollBar.vertical: ScrollBar {
		id: scrollbar
        rightPadding: Math.round(8 * DefaultStyle.dp)
		
		active: true
		interactive: true
		policy: mainItem.contentHeight > mainItem.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
	}

	section {
		criteria: ViewSection.FullString
		delegate: Text {
            topPadding: Math.round(24 * DefaultStyle.dp)
            bottomPadding: Math.round(16 * DefaultStyle.dp)
			text: section
            height: Math.round(29 * DefaultStyle.dp) + topPadding + bottomPadding
			wrapMode: Text.NoWrap
			font {
                pixelSize: Math.round(20 * DefaultStyle.dp)
                weight: Math.round(800 * DefaultStyle.dp)
				capitalization: Font.Capitalize
			}
		}
		property: '$sectionMonth'
	}
	
	delegate: FocusScope {
		id: itemDelegate
        height: Math.round(63 * DefaultStyle.dp) + (!isFirst && dateDay.visible ? topOffset : 0)
		width: mainItem.width
		enabled: !isCanceled && haveModel
		
		property var itemGui: $modelData
		// Do not use itemAtIndex because of caching items. Using getAt ensure to have a GUI
		property var previousConfInfoGui : mainItem.model.getAt(index-1)
		property var dateTime: itemGui.core ? itemGui.core.dateTime : UtilsCpp.getCurrentDateTime()
		property string day : UtilsCpp.toDateDayNameString(dateTime)
		property string dateString:  UtilsCpp.toDateString(dateTime)
		property string previousDateString: previousConfInfoGui ? UtilsCpp.toDateString(previousConfInfoGui.core ? previousConfInfoGui.core.dateTime : UtilsCpp.getCurrentDateTime()) : ''
		property bool isFirst : ListView.previousSection !== ListView.section
        property real topOffset: (dateDay.visible && !isFirst? Math.round(8 * DefaultStyle.dp) : 0)
		property var endDateTime: itemGui.core ? itemGui.core.endDateTime : UtilsCpp.getCurrentDateTime()
		property bool haveModel: itemGui.core ? itemGui.core.haveModel : false
		property bool isCanceled: itemGui.core ? itemGui.core.state === LinphoneEnums.ConferenceInfoState.Cancelled : false
		property bool isSelected: itemGui.core == mainItem.selectedConference?.core
		
		RowLayout{
			id: delegateIn
			anchors.fill: parent
			anchors.topMargin: !itemDelegate.isFirst && dateDay.visible ? itemDelegate.topOffset : 0
			spacing: 0
			Item{
                Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
				visible: !dateDay.visible
			}
			ColumnLayout {
				id: dateDay
				Layout.fillWidth: false
                Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
                Layout.minimumWidth: Math.round(32 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(51 * DefaultStyle.dp)
				visible: previousDateString.length == 0 || previousDateString != dateString
				spacing: 0
				Text {
                    Layout.preferredHeight: Math.round(19 * DefaultStyle.dp)
					Layout.alignment: Qt.AlignCenter
					text: day.substring(0,3) + '.'
					color: DefaultStyle.main2_500main
					wrapMode: Text.NoWrap
					elide: Text.ElideNone
					font {
                        pixelSize: Typography.p1.pixelSize
                        weight: Typography.p1.weight
						capitalization: Font.Capitalize
					}
				}
				Rectangle {
					id: dayNum
                    Layout.preferredWidth: Math.round(32 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(32 * DefaultStyle.dp)
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
                            pixelSize: Math.round(20 * DefaultStyle.dp)
                            weight: Math.round(800 * DefaultStyle.dp)
						}
					}
				}
				Item{Layout.fillHeight:true;Layout.fillWidth: true}
			}
			Item {
                Layout.preferredWidth: Math.round(265 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(63 * DefaultStyle.dp)
                Layout.leftMargin: Math.round(23 * DefaultStyle.dp)
				Rectangle {
					id: conferenceInfoDelegate
					anchors.fill: parent
					anchors.rightMargin: 5	// margin to avoid clipping shadows at right
                    radius: Math.round(10 * DefaultStyle.dp)
					visible: itemDelegate.haveModel || itemDelegate.activeFocus
					color: itemDelegate.isSelected ? DefaultStyle.main2_200 : DefaultStyle.grey_0 // mainItem.currentIndex === index
					ColumnLayout {
						anchors.fill: parent
						anchors.left: parent.left
                        anchors.leftMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.rightMargin: Math.round(16 * DefaultStyle.dp)
                        anchors.topMargin: Math.round(10 * DefaultStyle.dp)
                        anchors.bottomMargin: Math.round(10 * DefaultStyle.dp)
                        spacing: Math.round(2 * DefaultStyle.dp)
						visible: itemDelegate.haveModel
						RowLayout {
                            spacing: Math.round(8 * DefaultStyle.dp)
							EffectImage {
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							}
							Text {
								text: itemGui.core? itemGui.core.subject : ""
								Layout.fillWidth: true
								maximumLineCount: 1
								font {
                                    pixelSize: Typography.p2.pixelSize
                                    weight: Typography.p2.weight
								}
							}
						}
						Text {
                            //: "Réunion annulée"
                            text: itemDelegate.isCanceled ? qsTr("meeting_info_cancelled") : UtilsCpp.toDateHourString(dateTime) + " - " + UtilsCpp.toDateHourString(endDateTime)
							color: itemDelegate.isCanceled ? DefaultStyle.danger_500main : DefaultStyle.main2_500main
							font {
                                pixelSize: Typography.p1.pixelSize
                                weight: Typography.p1.weight
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
                    anchors.rightMargin: Math.round(5 * DefaultStyle.dp) // margin to avoid clipping shadows at right
                    anchors.leftMargin: Math.round(16 * DefaultStyle.dp)
					verticalAlignment: Text.AlignVCenter
					visible: !itemDelegate.haveModel
                    //: "Aucune réunion aujourd'hui"
                    text: qsTr("meetings_list_no_meeting_for_today")
					lineHeightMode: Text.FixedHeight
                    lineHeight: Math.round(18 * DefaultStyle.dp)
					font {
                        pixelSize: Typography.p2.pixelSize
                        weight: Typography.p2.weight
					}
				}
				MouseArea {
					hoverEnabled: mainItem.hoverEnabled
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					visible: itemDelegate.haveModel
					onClicked: {
						mainItem.selectIndex(index)
					}
				}
			}
		}
	}
}
