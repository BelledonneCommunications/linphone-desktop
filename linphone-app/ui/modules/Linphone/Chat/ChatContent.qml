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
Column{
	id: mainItem
	property ContentModel contentModel
	
	property int fitHeight: message.fitHeight + fileMessage.fitHeight + audioMessage.fitHeight
	property int fitWidth: message.fitWidth + fileMessage.fitWidth + audioMessage.fitWidth
	property color backgroundColor
	property string lastTextSelected
	property alias textColor: message.color
	property alias textFont: message.font
	
	signal rightClicked()
	
	height: fitHeight
	anchors.left: parent ? parent.left : undefined
	anchors.right: parent ? parent.right : undefined
	
	spacing: 0
	
	property bool isOutgoing : contentModel && contentModel.chatMessageModel && (contentModel.chatMessageModel.isOutgoing  || contentModel.chatMessageModel.state == LinphoneEnums.ChatMessageStateIdle);
	
	ChatAudioMessage{
		id: audioMessage
		contentModel: mainItem.contentModel
		visible: contentModel
	}
	ChatFileMessage{
		id: fileMessage
		contentModel: mainItem.contentModel
		width: parent.width
	}
	ChatTextMessage {
		id: message
		contentModel: mainItem.contentModel
		onLastTextSelectedChanged: mainItem.lastTextSelected = lastTextSelected
		color: isOutgoing ? ChatStyle.entry.message.outgoing.text.color : ChatStyle.entry.message.incoming.text.color
		onRightClicked: mainItem.rightClicked()
	}
}