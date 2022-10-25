import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import ColorsList 1.0

import UtilsCpp 1.0

import 'Timeline.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
Item {
	id: mainItem
	property TimelineModel timelineModel
	property bool optionsToggled: false
	property int modelIndex: 0
	
	height: TimelineStyle.contact.height
	width: parent ? parent.width : 0
	
	state: optionsToggled ? 'options' : 'normal'
	states: [State {
			name: "normal"
		}, State {
			name: "options"
		}
	]
	
	transitions: [Transition {
			from: 'normal'
			to: 'options'
			//NumberAnimation { target: contactView; property: 'x'; to:-contactView.width; duration: 200;}
			NumberAnimation { target: optionsView; property: 'x'; to:0; duration: 200;}
		},
		Transition {
			from: 'options'
			to: 'normal'
			//NumberAnimation { target: contactView; property: 'x'; to:0; duration: 200;}
			NumberAnimation { target: optionsView; property: 'x'; to:optionsView.width; duration: 200;}
		}
	]
	
	
	Contact {
		id: contactView
		property bool isSelected: mainItem.timelineModel != undefined && mainItem.timelineModel.selected	//view.currentIndex === index
		
		height: mainItem.height
		width: mainItem.width
		color: isSelected
			   ? TimelineStyle.contact.backgroundColor.selected
			   : (
					 mainItem.modelIndex % 2 == 0
					 ? TimelineStyle.contact.backgroundColor.a
					 : TimelineStyle.contact.backgroundColor.b
					 )
		displayUnreadMessageCount: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
		entry: mainItem.timelineModel && mainItem.timelineModel.chatRoomModel
		subtitleColor: isSelected
						 ? TimelineStyle.contact.subtitle.color.selected
						 : TimelineStyle.contact.subtitle.color.normal
		titleColor: isSelected
					   ? TimelineStyle.contact.title.color.selected
					   : TimelineStyle.contact.title.color.normal
		showSubtitle: mainItem.timelineModel && (mainItem.timelineModel.chatRoomModel && (mainItem.timelineModel.chatRoomModel.isOneToOne || !mainItem.timelineModel.chatRoomModel.isConference))
		TooltipArea {	
			id: contactTooltip						
			text: mainItem.timelineModel && UtilsCpp.toDateTimeString(mainItem.timelineModel.chatRoomModel.lastUpdateTime)
			isClickable: true
		}
		Icon{
			icon: TimelineStyle.ephemeralTimer.icon
			iconSize: TimelineStyle.ephemeralTimer.iconSize
			overwriteColor:  mainItem.timelineModel && mainItem.timelineModel.selected ? TimelineStyle.ephemeralTimer.selectedTimerColor : TimelineStyle.ephemeralTimer.timerColor
			anchors.right:parent.right
			anchors.bottom:parent.bottom
			anchors.bottomMargin: 7
			anchors.rightMargin: 7
			visible: mainItem.timelineModel && mainItem.timelineModel.chatRoomModel.ephemeralEnabled
		}
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			propagateComposedEvents: true
			preventStealing: false
			onClicked: {
				if(mouse.button == Qt.LeftButton){
					mainItem.timelineModel.selected = true
				}else{
					mainItem.optionsToggled = !mainItem.optionsToggled
				}
			}
		}
	}
	Item{
		id: optionsView
		
		height: mainItem.height
		width: mainItem.width
		
		x:width
		visible: x!=width
		RowLayout{
			anchors.fill: parent
			MouseArea {
				Layout.fillHeight: true
				Layout.fillWidth: true
				onClicked: {
					mainItem.optionsToggled = !mainItem.optionsToggled
				}
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.preferredWidth: optionsLayout.width
				
				color: contactView.color
				MouseArea {// Grabber
					anchors.fill: parent
					cursorShape: Qt.ArrowCursor
				}
				RowLayout{
					id: optionsLayout
					anchors.centerIn: parent
					/* TODO
					CheckBoxText {
						id: securedCheckBox
						Layout.alignment: Qt.AlignCenter
						text: ''
						
						onClicked: {
						
						}
					}*/
					ActionButton{
						id: deleteButton
						Layout.alignment: Qt.AlignCenter
						Layout.rightMargin: 6
						
						isCustom: true
						colorSet: contactView.isSelected ? TimelineStyle.selectedDeleteAction : TimelineStyle.deleteAction
						onClicked: window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
																  //: 'Are you sure you want to delete and leave this timeline?'
																  descriptionText: qsTr('deleteTimeline'),
															  }, function (status) {
																  if (status) {
																	  mainItem.timelineModel.chatRoomModel.deleteChatRoom()
																  }
															  })
						TooltipArea {
							//: 'After confirmation, it will erase all history, leave the chat room if it is a group chat and delete it in database.'
							text: qsTr('deleteTimelineTooltip')
						}
					}
				}
			}
		}
	}
	
}