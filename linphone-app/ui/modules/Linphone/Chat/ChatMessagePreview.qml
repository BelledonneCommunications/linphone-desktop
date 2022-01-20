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
	spacing: 0
	Layout.preferredHeight: (replyPreview.visible ? replyPreview.height : 0 ) + (audioPreview.visible ? audioPreview.height : 0)
	Layout.maximumHeight: Layout.preferredHeight
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