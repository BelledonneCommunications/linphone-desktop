import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Row {
	property string _type: {
		var status = $chatEntry.status
		if (status == LinphoneEnums.CallStatusSuccess) {
			if (!$chatEntry.isStart) {
				return 'ended_call'
			}
			return $chatEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status == LinphoneEnums.CallStatusDeclined) {
			return $chatEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
		}
		if (status == LinphoneEnums.CallStatusMissed) {
			return $chatEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
		}
		if (status == LinphoneEnums.CallStatusAborted) {
			return $chatEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status == LinphoneEnums.CallStatusEarlyAborted) {
			return $chatEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
		}
		if (status == LinphoneEnums.CallStatusAcceptedElsewhere) {
			return $chatEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
		}
		if (status == LinphoneEnums.CallStatusDeclinedElsewhere) {
			return $chatEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
		}
		
		return 'unknown_call_event'
	}
	
	height: ChatStyle.entry.lineHeight
	spacing: ChatStyle.entry.message.extraContent.spacing
	
	Icon {
		height: parent.height
		icon: _type
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
		
		color: ChatStyle.entry.event.text.color
		font {
			bold: true
			pointSize: ChatStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: qsTr(Utils.snakeToCamel(_type))
		verticalAlignment: Text.AlignVCenter
		ChatMenu{
			id:chatMenu
			height: parent.height
			width: textArea.width
			
			deliveryCount: 0
			onRemoveEntryRequested: removeEntry()
		}
	}
	
	ActionButton {
		height: ChatStyle.entry.lineHeight
		
		icon: 'chat_menu'
		iconSize: ChatStyle.entry.deleteIconSize
		visible: isHoverEntry()
		
		onClicked: chatMenu.open()
	}
}
