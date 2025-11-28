import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic

import Linphone
import QtQml
import UtilsCpp

import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ListView {
	id: mainItem
	property string searchBarText
	property bool hoverEnabled: true	
	property var delegateButtons
	property ConferenceInfoGui selectedConference
	property bool _moveToIndex: false
    property bool loading: false
    property real busyIndicatorSize: Utils.getSizeWithScreenRatio(60)

	clip: true
	cacheBuffer: height/2
	
    spacing: Utils.getSizeWithScreenRatio(8)
	highlightFollowsCurrentItem: false

	signal meetingDeletionRequested(ConferenceInfoGui confInfo, bool canCancel)
	
	function selectIndex(index){
		mainItem.currentIndex = index
	}
		
	function resetSelections(){
		mainItem.selectedConference = null
		mainItem.currentIndex = -1
	}

	function scrollToCurrentDate() {
		currentIndex = -1
		confInfoProxy.selectData(confInfoProxy.getCurrentDateConfInfo())
		moveToCurrentItem()
	}
	
//----------------------------------------------------------------	
	function moveToCurrentItem(){
		if(mainItem.currentIndex >= 0) 
			mainItem.positionViewAtIndex(mainItem.currentIndex, ListView.Contain)
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
	
	// Let some space for better UI
	footer: Item{height: Utils.getSizeWithScreenRatio(38)}

	model: ConferenceInfoProxy {
		id: confInfoProxy
		filterText: searchBarText
		filterType: ConferenceInfoProxy.None
        initialDisplayItems: Math.max(20, Math.round(2 * mainItem.height / Utils.getSizeWithScreenRatio(63)))
		displayItemsStep: initialDisplayItems/2
		Component.onCompleted: {
            mainItem.loading = false
        }
		onModelAboutToBeReset: {
            mainItem.loading = true
        }
		onModelReset: {
			mainItem.loading = false
			selectData(getCurrentDateConfInfo())
		}
		function selectData(confInfoGui){
			mainItem.currentIndex = loadUntil(confInfoGui)
		}
		onConferenceInfoCreated: (confInfoGui) => {
			selectData(confInfoGui)
		}
		onConferenceInfoUpdated: (confInfoGui) => {
			selectData(confInfoGui)
		}
	}

	BusyIndicator {
        anchors.horizontalCenter: mainItem.horizontalCenter
        visible: mainItem.loading
        height: visible ? mainItem.busyIndicatorSize : 0
        width: mainItem.busyIndicatorSize
        indicatorHeight: mainItem.busyIndicatorSize
        indicatorWidth: mainItem.busyIndicatorSize
        indicatorColor: DefaultStyle.main1_500_main
    }
	
	ScrollBar.vertical: ScrollBar {
		id: scrollbar
        rightPadding: Utils.getSizeWithScreenRatio(8)
		
		active: true
		interactive: true
		policy: mainItem.contentHeight > mainItem.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
	}

	section {
		criteria: ViewSection.FullString
		delegate: Text {
            topPadding: Utils.getSizeWithScreenRatio(24)
            bottomPadding: Utils.getSizeWithScreenRatio(16)
			text: section
            height: Utils.getSizeWithScreenRatio(29) + topPadding + bottomPadding
			wrapMode: Text.NoWrap
			font {
                pixelSize: Utils.getSizeWithScreenRatio(20)
                weight: Utils.getSizeWithScreenRatio(800)
				capitalization: Font.Capitalize
			}
		}
		property: '$sectionMonth'
	}
	
	delegate: FocusScope {
		id: itemDelegate
		visible: !mainItem.loading
        height: Utils.getSizeWithScreenRatio(63) + (!isFirst && dateDay.visible ? topOffset : 0)
		width: mainItem.width
		enabled: haveModel
		
		property var itemGui: $modelData
		// Do not use itemAtIndex because of caching items. Using getAt ensure to have a GUI
		property var previousConfInfoGui : mainItem.model.getAt(index-1)
		property var dateTime: itemGui.core ? itemGui.core.dateTime : UtilsCpp.getCurrentDateTime()
		property string day : UtilsCpp.toDateDayNameString(dateTime)
		property string dateString:  UtilsCpp.toDateString(dateTime)
		property string previousDateString: previousConfInfoGui ? UtilsCpp.toDateString(previousConfInfoGui.core ? previousConfInfoGui.core.dateTime : UtilsCpp.getCurrentDateTime()) : ''
		property bool isFirst : ListView.previousSection !== ListView.section
        property real topOffset: (dateDay.visible && !isFirst) ? Utils.getSizeWithScreenRatio(8) : 0
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
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
				visible: !dateDay.visible
			}
			ColumnLayout {
				id: dateDay
				Layout.fillWidth: false
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
                Layout.minimumWidth: Utils.getSizeWithScreenRatio(32)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(51)
				visible: previousDateString.length == 0 || previousDateString != dateString
				spacing: 0
				Text {
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(19)
					Layout.alignment: Qt.AlignCenter
					text: day.substring(0,3) + '.'
					color: DefaultStyle.main2_500_main
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
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
					Layout.alignment: Qt.AlignCenter
					radius: height/2
					property var isCurrentDay: UtilsCpp.isCurrentDay(dateTime)

					color: isCurrentDay ? DefaultStyle.main1_500_main : "transparent"
					
					Text {
						anchors.centerIn: parent
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignHCenter
						text: UtilsCpp.toDateDayString(dateTime)
						color: dayNum.isCurrentDay ? DefaultStyle.grey_0 : DefaultStyle.main2_500_main
						wrapMode: Text.NoWrap
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(20)
                            weight: Utils.getSizeWithScreenRatio(800)
						}
					}
				}
				Item{Layout.fillHeight:true;Layout.fillWidth: true}
			}
			Item {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(265)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(63)
                Layout.leftMargin: Utils.getSizeWithScreenRatio(23)
				Rectangle {
					id: conferenceInfoDelegate
					anchors.fill: parent
					anchors.rightMargin: 5	// margin to avoid clipping shadows at right
                    radius: Utils.getSizeWithScreenRatio(10)
					visible: itemDelegate.haveModel || itemDelegate.activeFocus
					color: itemDelegate.isSelected ? DefaultStyle.main2_200 : DefaultStyle.grey_0 // mainItem.currentIndex === index
					ColumnLayout {
						anchors.fill: parent
						anchors.left: parent.left
                        anchors.leftMargin: Utils.getSizeWithScreenRatio(16)
                        anchors.rightMargin: Utils.getSizeWithScreenRatio(16)
                        anchors.topMargin: Utils.getSizeWithScreenRatio(10)
                        anchors.bottomMargin: Utils.getSizeWithScreenRatio(10)
                        spacing: Utils.getSizeWithScreenRatio(2)
						visible: itemDelegate.haveModel
						RowLayout {
                            spacing: Utils.getSizeWithScreenRatio(8)
							EffectImage {
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
							color: itemDelegate.isCanceled ? DefaultStyle.danger_500_main : DefaultStyle.main2_500_main
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
                    anchors.rightMargin: Utils.getSizeWithScreenRatio(5) // margin to avoid clipping shadows at right
                    anchors.leftMargin: Utils.getSizeWithScreenRatio(16)
					verticalAlignment: Text.AlignVCenter
					visible: !itemDelegate.haveModel
                    //: "Aucune réunion aujourd'hui"
                    text: qsTr("meetings_list_no_meeting_for_today")
					lineHeightMode: Text.FixedHeight
                    lineHeight: Utils.getSizeWithScreenRatio(18)
					font {
                        pixelSize: Typography.p2.pixelSize
                        weight: Typography.p2.weight
					}
				}
				MouseArea {
					id: mouseArea
					hoverEnabled: mainItem.hoverEnabled
					anchors.fill: parent
					cursorShape: itemDelegate.isCanceled ? Qt.ArrowCursor : Qt.PointingHandCursor
					visible: itemDelegate.haveModel
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					onClicked: (mouse) => {
						if (mouse.button === Qt.RightButton) {
							deletePopup.x = mouse.x
							deletePopup.y = mouse.y
							deletePopup.open()
						}
						else if (!itemDelegate.isCanceled) mainItem.selectIndex(index)
					}
					Popup {
						id: deletePopup
						parent: mouseArea
        				padding: Utils.getSizeWithScreenRatio(10)
        				closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnPressOutside | Popup.CloseOnEscape
						contentItem: IconLabelButton {
							style: ButtonStyle.hoveredBackgroundRed
							property var isMeObj: UtilsCpp.isMe(itemDelegate.itemGui?.core?.organizerAddress)
							property bool canCancel: isMeObj && isMeObj.value && itemDelegate.itemGui?.core?.state !== LinphoneEnums.ConferenceInfoState.Cancelled
							icon.source: AppIcons.trashCan
							//: "Supprimer la réunion"
							text: qsTr("meeting_info_delete")
							
							onClicked: {
								if (itemDelegate.itemGui) {
									mainItem.meetingDeletionRequested(itemDelegate.itemGui, canCancel)
									deletePopup.close()
								}
							}
						}
					}
				}
			}
		}
	}
}
