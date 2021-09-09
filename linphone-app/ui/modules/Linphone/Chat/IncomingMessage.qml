import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import LinphoneUtils 1.0

// =============================================================================

RowLayout {
	id:mainRow
	implicitHeight: message.height
	spacing: 0
	
	Item {
		Layout.alignment: Qt.AlignTop
		Layout.preferredHeight: ChatStyle.entry.lineHeight
		Layout.preferredWidth: ChatStyle.entry.metaWidth
		
		Avatar {
			id:avatar
			anchors.centerIn: parent
			height: ChatStyle.entry.message.incoming.avatarSize
			image: $chatEntry.contactModel? $chatEntry.contactModel.vcard.avatar : '' //chat.sipAddressObserver.contact ? chat.sipAddressObserver.contact.vcard.avatar : ''
			username: $chatEntry.fromDisplayName
			
			width: ChatStyle.entry.message.incoming.avatarSize
			
			// The avatar is only visible for the first message of a incoming messages sequence.
			visible: {
				if (index <= 0) {
					return true // 1. First message, so visible.
				}
				var previousEntry = proxyModel.getAt(index - 1)
				return !$chatEntry.isOutgoing && (// Only outgoing
							!previousEntry	//No previous entry
							|| previousEntry.type != ChatRoomModel.MessageEntry	// Previous entry is a message
							|| previousEntry.fromSipAddress != $chatEntry.fromSipAddress	// Different user
							|| (new Date(previousEntry.timestamp)).setHours(0, 0, 0, 0) != (new Date($chatEntry.timestamp)).setHours(0, 0, 0, 0)	// Same day == section
								)
			}
			TooltipArea{
				delay:0
				text:avatar.username+'\n'+$chatEntry.fromSipAddress
				tooltipParent:mainRow
				isClickable: true
				onDoubleClicked: {
					window.mainSearchBar.text = $chatEntry.fromSipAddress
					}
			}
		}
	}
	
	Message {
		id: message
		
		Layout.fillWidth: true
		
		// Not a style. Workaround to avoid a 0 width.
		// Arbitrary value.
		Layout.minimumWidth: 1
		
		backgroundColor: ChatStyle.entry.message.incoming.backgroundColor
		color: ChatStyle.entry.message.incoming.text.color
		pointSize: ChatStyle.entry.message.incoming.text.pointSize
	}
}
