import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import ColorsList 1.0

// =============================================================================
// Full content display with reply and forward. These modules need to be splitted because of cyclic dependencies.
// See ChatContent

Column{
	id: mainItem
	property ChatMessageModel chatMessageModel: null
	property int availableWidth	//const
	
// Readonly
	property int bestWidth: Math.min(availableWidth, Math.max(forwardMessage.fitWidth, replyMessage.fitWidth, chatContent.bestWidth ))
	property alias filesBestWidth: chatContent.filesBestWidth
	property alias filesCount: chatContent.filesCount
	property alias textsBestWidth: chatContent.textsBestWidth
	property alias textsCount: chatContent.textsCount
	
	signal isFileHoveringChanged(bool isFileHovering)
	signal lastTextSelectedChanged(string lastTextSelected)
	signal rightClicked()
	signal conferenceIcsCopied()
	signal goToMessage(var message)
	
	spacing: 0
	ChatForwardMessage{
		id: forwardMessage
		mainChatMessageModel: mainItem.chatMessageModel
		visible: mainChatMessageModel && mainChatMessageModel.isForward
		availableWidth: mainItem.availableWidth
	}
	ChatReplyMessage{
		id: replyMessage
		z: 1
		mainChatMessageModel: mainItem.chatMessageModel
		visible: mainChatMessageModel && mainChatMessageModel.isReply
		availableWidth: mainItem.availableWidth
		onGoToMessage: mainItem.goToMessage(message)
	}
	ChatContent{
		id: chatContent
		chatMessageModel: mainItem.chatMessageModel
		availableWidth: mainItem.availableWidth
		width: parent.width
		
		onIsFileHoveringChanged: mainItem.isFileHoveringChanged(isFileHovering)
		onLastTextSelectedChanged: mainItem.lastTextSelectedChanged(lastTextSelected)
		onRightClicked: mainItem.rightClicked()
		onConferenceIcsCopied: mainItem.conferenceIcsCopied()
	}
}
