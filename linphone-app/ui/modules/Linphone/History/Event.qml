import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

// =============================================================================

Row {
	id: mainItem
	signal entryClicked(var entry)
	
	property var _sipAddressObserver: $historyEntry.sipAddress ? SipAddressesModel.getSipAddressObserver($historyEntry.sipAddress, '') : $historyEntry.title
	property QtObject iconData
	property string translation
	Component.onDestruction: _sipAddressObserver=null// Need to set it to null because of not calling destructor if not.
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
	
	height: HistoryStyle.entry.lineHeight
	spacing: HistoryStyle.entry.message.extraContent.spacing
	
	Icon {
		height: parent.height
		icon: mainItem.iconData ? mainItem.iconData.icon : null
		overwriteColor: mainItem.iconData ? mainItem.iconData.colorModel.color: null
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
		
		color: HistoryStyle.entry.event.text.colorModel.color
		font {
			bold: true
			pointSize: HistoryStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: mainItem.translation ? qsTr(mainItem.translation) +' - ' : ' - '
		verticalAlignment: Text.AlignVCenter
		MouseArea{
			anchors.fill:parent
			onClicked: entryClicked($historyEntry)
		}
	}
	Text {
		color: HistoryStyle.entry.event.text.colorModel.color
		font {
			bold: true
			pointSize: HistoryStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: $historyEntry && $historyEntry.title
				? $historyEntry.title
				: _sipAddressObserver 
					? ( UtilsCpp.getDisplayName(_sipAddressObserver.peerAddress || $historyEntry.sipAddress) || _sipAddressObserver)
					: ''
		verticalAlignment: Text.AlignVCenter
		MouseArea{
			anchors.fill:parent
			onClicked: entryClicked($historyEntry)
		}
	}
	ActionButton {
		isCustom: true
		backgroundRadius: 8
		colorSet: HistoryStyle.entry.deleteAction
		visible: isHoverEntry()
		
		onClicked: removeEntry()
	}
}
