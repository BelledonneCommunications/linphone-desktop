import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import ColorsList 1.0

import UtilsCpp 1.0

import 'Timeline.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
Rectangle {
	id: mainItem
	property CallHistoryModel callHistoryModel
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
			property bool isSelected: mainItem.callHistoryModel != undefined && mainItem.callHistoryModel.selected
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
			entry: mainItem.callHistoryModel && (mainItem.callHistoryModel.conferenceInfoModel && mainItem.callHistoryModel
			|| SipAddressesModel.getSipAddressObserver(mainItem.callHistoryModel.remoteAddress, ''))
			
			property var subtitleSelectedColors: TimelineStyle.contact.subtitle.color.selected
			property var subtitleNormalColors: TimelineStyle.contact.subtitle.color.normal
			property var titleSelectedColors: TimelineStyle.contact.title.color.selected
			property var titleNormalColors: TimelineStyle.contact.title.color.normal
			
			function getIconData(){
				var iconData
				if(!mainItem.callHistoryModel)
					return HistoryStyle.entry.event.unknownCallEvent
				if (mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusSuccess) {
					if(!mainItem.callHistoryModel.lastCallIsStart){
						iconData = HistoryStyle.entry.event.endedCall
					}else if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.outgoingCall
					}else{
						iconData = HistoryStyle.entry.event.incomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusDeclined) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.declinedOutgoingCall
					}else{
						iconData = HistoryStyle.entry.event.declinedIncomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusMissed) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.missedOutgoingCall
					}else{
						iconData = HistoryStyle.entry.event.missedIncomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusAborted) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.outgoingCall
					}else{
						iconData = HistoryStyle.entry.event.incomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusDeclined) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.declinedOutgoingCall
					}else{
						iconData = HistoryStyle.entry.event.declinedIncomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusEarlyAborted) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.missedOutgoingCall
					}else{
						iconData = HistoryStyle.entry.event.missedIncomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusAcceptedElsewhere) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.outgoingCall
					}else{
						iconData = HistoryStyle.entry.event.incomingCall
					}
				}else if(mainItem.callHistoryModel.lastCallStatus == LinphoneEnums.CallStatusDeclinedElsewhere) {
					if(mainItem.callHistoryModel.lastCallIsOutgoing ){
						iconData = HistoryStyle.entry.event.declinedOutgoingCall
					}else{
						iconData = HistoryStyle.entry.event.declinedIncomingCall
					}
				}else {
					iconData = HistoryStyle.entry.event.unknownCallEvent
				}
				return iconData
			}
			
			subtitleColor: isSelected
							 ? subtitleSelectedColors.color
							 : subtitleNormalColors.color
			titleColor: isSelected
						   ? titleSelectedColors.color
						   : titleNormalColors.color
			subtitleIconData: getIconData()
			subtitleText: mainItem.callHistoryModel && UtilsCpp.toDateTimeString(mainItem.callHistoryModel.lastCallDate, 'yyyy/MM/dd - hh:mm') || ''
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				propagateComposedEvents: true
				preventStealing: false
				onClicked: {
					if(mouse.button == Qt.LeftButton){
						if(mainItem.callHistoryModel)
							mainItem.callHistoryModel.selectOnly()
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
				visible: false //SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled
				Icon{
					id: notificationsIcon
					Layout.preferredHeight: TimelineStyle.status.iconSize
					Layout.preferredWidth: TimelineStyle.status.iconSize
					icon: TimelineStyle.disabledNotifications.icon
					iconSize: TimelineStyle.status.iconSize
					//overwriteColor:  mainItem.timelineModel && mainItem.timelineModel.selected ? TimelineStyle.disabledNotifications.selectedColorModel.color : TimelineStyle.disabledNotifications.colorModel.color
					//visible: mainItem.timelineModel && !mainItem.timelineModel.chatRoomModel.notificationsEnabled
				}
				Icon{
					id: ephemeralIcon
					Layout.preferredHeight: TimelineStyle.status.iconSize
					Layout.preferredWidth: TimelineStyle.status.iconSize
					icon: TimelineStyle.ephemeralTimer.icon
					iconSize: TimelineStyle.status.iconSize
					//overwriteColor:  mainItem.timelineModel && mainItem.timelineModel.selected ? TimelineStyle.ephemeralTimer.selectedTimerColor.color : TimelineStyle.ephemeralTimer.timerColor.color
					//visible: mainItem.timelineModel && mainItem.timelineModel.chatRoomModel.ephemeralEnabled
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
					if( mainItem.callHistoryModel)
						mainItem.actions[index].handler(	// Do not use modelData on functions
							mainItem.callHistoryModel
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
				}
			}
		}
	}
}