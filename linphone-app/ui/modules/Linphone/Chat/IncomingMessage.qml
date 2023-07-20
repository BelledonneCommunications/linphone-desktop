import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import UtilsCpp 1.0

// =============================================================================

RowLayout {
	id:mainRow
	
	Layout.fillWidth: true
	
	property alias isHovering: message.isHovering
	property alias isTopGrouped: message.isTopGrouped
	property alias isBottomGrouped: message.isBottomGrouped
	
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	signal goToMessage(ChatMessageModel message)
	signal conferenceIcsCopied()
	signal addContactClicked(string contactAddress)
	signal viewContactClicked(string contactAddress)
  
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
			visible: index <= 0 ? true // 1. First message, so visible.
								: $chatEntry && !$chatEntry.isOutgoing && !mainRow.isTopGrouped || false

			TooltipArea{
				delay:0
				text:avatar.username+'\n'+$chatEntry.fromSipAddress
				maxWidth: mainRow.width
				isClickable: true
				onClicked: {
					window.mainSearchBar.text = UtilsCpp.toDisplayString($chatEntry.fromSipAddress, SettingsModel.sipDisplayMode)
				}
			}
		}
	}
	
	Message {
		id: message
		
		onCopyAllDone: mainRow.copyAllDone()
		onCopySelectionDone: mainRow.copySelectionDone()
		onReplyClicked: mainRow.replyClicked()
		onForwardClicked: mainRow.forwardClicked()
		onGoToMessage: mainRow.goToMessage(message)
		onConferenceIcsCopied: mainRow.conferenceIcsCopied()
		onAddContactClicked: mainRow.addContactClicked(contactAddress)
		onViewContactClicked: mainRow.viewContactClicked(contactAddress)
		
		Layout.fillWidth: true
		Layout.rightMargin: 10
		
		// Not a style. Workaround to avoid a 0 width.
		// Arbitrary value.
		Layout.minimumWidth: 1
		
		backgroundColorModel: ChatStyle.entry.message.incoming.backgroundColor
	}
}
