import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

// =============================================================================

Row {
	id: mainItem
	signal entryClicked(string sipAddress)
	
	readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver($historyEntry.sipAddress, '')
	property QtObject iconData
	property string translation
	Component.onCompleted: {
		if ($historyEntry.status == LinphoneEnums.CallStatusSuccess) {
			if(!$historyEntry.isStart){
				iconData = HistoryStyle.entry.event.endedCall
				translation ='endedCall'
			}else if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusDeclined) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusMissed) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.missedOutgoingCall
				translation ='missedOutgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.missedIncomingCall
				translation ='missedIncomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusAborted) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusDeclined) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusEarlyAborted) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.missedOutgoingCall
				translation ='missedOutgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.missedIncomingCall
				translation ='missedIncomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusAcceptedElsewhere) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.outgoingCall
				translation ='outgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.incomingCall
				translation ='incomingCall'
			}
		}else if($historyEntry.status == LinphoneEnums.CallStatusDeclinedElsewhere) {
			if($historyEntry.isOutgoing ){
				iconData = HistoryStyle.entry.event.declinedOutgoingCall
				translation ='declinedOutgoingCall'
			}else{
				iconData = HistoryStyle.entry.event.declinedIncomingCall
				translation ='declinedIncomingCall'
			}
		}else {
			iconData = HistoryStyle.entry.event.unknownCallEvent
			translation = 'unknownCallEvent'
		}
	}
	/*
	property string _type: {
		var status = $historyEntry.status
		
		if (status === HistoryModel.CallStatusSuccess) {
			if (!$historyEntry.isStart) {
				return 'ended_call'
			}
			return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status === HistoryModel.CallStatusDeclined) {
			return $historyEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
		}
		if (status === HistoryModel.CallStatusMissed) {
			return $historyEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
		}
		if (status === HistoryModel.CallStatusAborted) {
			return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status === HistoryModel.CallStatusEarlyAborted) {
			return $historyEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
		}
		if (status === HistoryModel.CallStatusAcceptedElsewhere) {
			return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status === HistoryModel.CallStatusDeclinedElsewhere) {
			return $historyEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
		}
		
		return 'unknown_call_event'
	}*/
	
	height: HistoryStyle.entry.lineHeight
	spacing: HistoryStyle.entry.message.extraContent.spacing
	
	Icon {
		height: parent.height
		icon: mainItem.iconData ? mainItem.iconData.icon : null
		overwriteColor: mainItem.iconData ? mainItem.iconData.color: null
		iconSize: HistoryStyle.entry.event.iconSize
		width: HistoryStyle.entry.metaWidth
	}
	
	Text {
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
		
		color: HistoryStyle.entry.event.text.color
		font {
			bold: true
			pointSize: HistoryStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: mainItem.translation ? qsTr(mainItem.translation) +' - ' : ' - '
		verticalAlignment: Text.AlignVCenter
	}
	Text {
		color: HistoryStyle.entry.event.text.color
		font {
			bold: true
			pointSize: HistoryStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: UtilsCpp.getDisplayName(_sipAddressObserver.peerAddress)
		verticalAlignment: Text.AlignVCenter
		MouseArea{
			anchors.fill:parent
			onClicked:entryClicked($historyEntry.sipAddress)
		}
	}
	ActionButton {
		//height: HistoryStyle.entry.lineHeight
		isCustom: true
		backgroundRadius: 8
		colorSet: HistoryStyle.entry.deleteAction
		visible: isHoverEntry()
		
		onClicked: removeEntry()
	}
}
