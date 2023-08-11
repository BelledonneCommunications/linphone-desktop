import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Row {
	id: mainItem
	property QtObject iconData
	property string translation
	property bool isHovering : false
	property bool isTopGrouped: false
	property bool isBottomGrouped: false
	Component.onCompleted: {
		if ($chatEntry.status == LinphoneEnums.CallStatusSuccess) {
			if(!$chatEntry.isStart){
				iconData = ChatStyle.entry.event.endedCall
				translation ='endedCall'
			}else if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = ChatStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusDeclined) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = ChatStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusMissed) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.missedOutgoingCall
				translation ='missedOutgoingCall'
			}else{
				iconData = ChatStyle.entry.event.missedIncomingCall
				translation ='missedIncomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusAborted) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = ChatStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusDeclined) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = ChatStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusEarlyAborted) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.missedOutgoingCall
				translation ='missedOutgoingCall'
			}else{
				iconData = ChatStyle.entry.event.missedIncomingCall
				translation ='missedIncomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusAcceptedElsewhere) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = ChatStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($chatEntry.status == LinphoneEnums.CallStatusDeclinedElsewhere) {
			if($chatEntry.isOutgoing ){
				iconData = ChatStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = ChatStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else {
			iconData = ChatStyle.entry.event.unknownCallEvent
			translation = 'unknownCallEvent'
		}
	}
	
	height: ChatStyle.entry.lineHeight
	spacing: ChatStyle.entry.message.extraContent.spacing
	
	layoutDirection: $chatEntry.isOutgoing ? Qt.RightToLeft : Qt.LeftToRight
	
	Icon {
		height: parent.height
		icon: mainItem.iconData ? mainItem.iconData.icon : null
		overwriteColor: mainItem.iconData ? mainItem.iconData.colorModel.color: null
		iconSize: ChatStyle.entry.event.iconSize
		width: ChatStyle.entry.metaWidth
	}
	
	Text {
		id:textArea
		Component {
			// Never created.
			// Private data for `lupdate`.
			Item {
				property var i18n: [
					QT_TR_NOOP('declinedIncomingCall'),
					QT_TR_NOOP('declinedOutgoingCall'),
					QT_TR_NOOP('endedCall'),
					QT_TR_NOOP('incomingCall'),
					QT_TR_NOOP('missedIncomingCall'),
					QT_TR_NOOP('missedOutgoingCall'),
					QT_TR_NOOP('outgoingCall')
				]
			}
		}
		
		color: ChatStyle.entry.event.text.colorModel.color
		font {
			bold: true
			pointSize: ChatStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: mainItem.translation ? qsTr(mainItem.translation) : ''
		verticalAlignment: Text.AlignVCenter
		ChatMenu{
			id:chatMenu
			height: parent.height
			width: textArea.width
			
			deliveryCount: 0
			isCallEvent: true
			onRemoveEntryRequested: removeEntry()
		}
	}
	
	ActionButton {
		height: ChatStyle.entry.menu.iconSize
		isCustom: true
		backgroundRadius: 8
		colorSet: ChatStyle.entry.menu
		
		visible: isHoverEntry()
		
		onClicked: chatMenu.open()
	}
}
