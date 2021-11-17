import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================
ColumnLayout{
	property alias replyChatRoomModel : replyPreview.chatRoomModel
	property int maxHeight: parent.height - ( audioPreview.visible ? audioPreview.height : 0)
	anchors.left: parent.left
	anchors.right: parent.right
	anchors.bottom: parent.bottom
	spacing: 0
	
	function hide(){
	}
	ChatReplyPreview{
		id: replyPreview
		Layout.fillWidth: true
	}
	ChatAudioPreview{
		id: audioPreview
		Layout.fillWidth: true
	}
}	