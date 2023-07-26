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
Rectangle {
	id: mainItem
	property TimelineModel timelineModel
	property bool optionsTogglable: true	// Right click => display/hide options
	property bool optionsToggled: false
	property int modelIndex: 0
	property var actions: []
	
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
	enabled: !contactView.showBusyIndicator
	
	color: contactView.isSelected
			   ? TimelineStyle.contact.backgroundColor.selected.color
			   : (
					 mainItem.modelIndex % 2 == 0
					 ? TimelineStyle.contact.backgroundColor.a.color
					 : TimelineStyle.contact.backgroundColor.b.color
					 )
	
	RowLayout{
		anchors.fill: parent
		anchors.rightMargin: 5
		spacing: 0
		Contact {
			id: contactView
			property bool isSelected: mainItem.timelineModel != undefined && mainItem.timelineModel.selected	//view.currentIndex === index
			Layout.fillHeight: true
			Layout.fillWidth: true
			color: isSelected
				   ? TimelineStyle.contact.backgroundColor.selected.color
				   : (
						 mainItem.modelIndex % 2 == 0
						 ? TimelineStyle.contact.backgroundColor.a.color
						 : TimelineStyle.contact.backgroundColor.b.color
						 )
			displayUnreadMessageCount: false
			entry: mainItem.timelineModel && mainItem.timelineModel.chatRoomModel
			
			property var subtitleSelectedColors: TimelineStyle.contact.subtitle.color.selected
			property var subtitleNormalColors: TimelineStyle.contact.subtitle.color.normal
			property var titleSelectedColors: TimelineStyle.contact.title.color.selected
			property var titleNormalColors: TimelineStyle.contact.title.color.normal
			
			subtitleColor: isSelected
							 ? subtitleSelectedColors.color
							 : subtitleNormalColors.color
			titleColor: isSelected
						   ? titleSelectedColors.color
						   : titleNormalColors.color
			showSubtitle: mainItem.timelineModel && (mainItem.timelineModel.chatRoomModel && (mainItem.timelineModel.chatRoomModel.isOneToOne || !mainItem.timelineModel.chatRoomModel.isConference))
			showBusyIndicator: mainItem.timelineModel && mainItem.timelineModel.updating
			TooltipArea {
				id: contactTooltip
				text: mainItem.timelineModel && UtilsCpp.toDateTimeString(mainItem.timelineModel.chatRoomModel.lastUpdateTime)
				isClickable: true
			}
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				propagateComposedEvents: true
				preventStealing: false
				onClicked: {
					if(mouse.button == Qt.LeftButton){
						mainItem.timelineModel.selected = true
					}else if(mainItem.optionsTogglable){
						mainItem.optionsToggled = !mainItem.optionsToggled
					}
				}
			}
		}
		ColumnLayout{
			spacing: 0
			Layout.maximumWidth: statusLayout.count > 0 || unreadMessageCounter.visible ? -1 : 0
			Layout.fillHeight: true
			RowLayout{
				Layout.alignment: Qt.AlignTop | Qt.AlignRight
				Layout.fillHeight: true
				spacing: 0
				ContactMessageCounter {
					id: unreadMessageCounter
					Layout.alignment: Qt.AlignTop
					Layout.preferredWidth: implicitWidth
					Layout.preferredHeight: implicitHeight
					Layout.rightMargin: 9
					displayCounter: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
					entry: contactView.entry
				}
			}
			RowLayout{
				id: statusLayout
				property int count : (ephemeralIcon.visible ? 1 : 0) + (notificationsIcon.visible ? 1 : 0)
				spacing: 0
				Layout.alignment: Qt.AlignBottom | Qt.AlignRight
				Layout.preferredHeight: TimelineStyle.status.iconSize
				visible: SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
				Icon{
					id: notificationsIcon
					Layout.preferredHeight: TimelineStyle.status.iconSize
					Layout.preferredWidth: TimelineStyle.status.iconSize
					icon: TimelineStyle.disabledNotifications.icon
					iconSize: TimelineStyle.status.iconSize
					overwriteColor:  mainItem.timelineModel && mainItem.timelineModel.selected ? TimelineStyle.disabledNotifications.selectedColorModel.color : TimelineStyle.disabledNotifications.colorModel.color
					visible: mainItem.timelineModel && !mainItem.timelineModel.chatRoomModel.notificationsEnabled
				}
				Icon{
					id: ephemeralIcon
					Layout.preferredHeight: TimelineStyle.status.iconSize
					Layout.preferredWidth: TimelineStyle.status.iconSize
					icon: TimelineStyle.ephemeralTimer.icon
					iconSize: TimelineStyle.status.iconSize
					overwriteColor:  mainItem.timelineModel && mainItem.timelineModel.selected ? TimelineStyle.ephemeralTimer.selectedTimerColor.color : TimelineStyle.ephemeralTimer.timerColor.color
					visible: mainItem.timelineModel && mainItem.timelineModel.chatRoomModel.ephemeralEnabled
				}
			}
		}
	}
	RowLayout{
		anchors.fill: parent
		anchors.rightMargin: 5
		visible: mainItem.actions.length > 0
		Item{// Spacer
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		Repeater {
			model: mainItem.actions
			
			ActionButton {
				isCustom: true
				backgroundRadius: 90
				colorSet: modelData.colorSet
				
				visible: modelData.visible
				
				onClicked: {
					mainItem.actions[index].handler(	// Do not use modelData on functions
						mainItem.timelineModel
					)
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
					if(mainItem.optionsTogglable)
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