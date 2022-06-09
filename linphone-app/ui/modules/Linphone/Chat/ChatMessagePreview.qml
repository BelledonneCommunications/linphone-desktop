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
	property int maxHeight: parent.height
	property int fitHeight: (replyPreview.visible ? replyPreview.height + replySeparator.height: 0 ) 
							+ (audioPreview.visible ? audioPreview.height + audioSeparator.height: 0)
							+ (filesPreview.visible ? filesPreview.height + filesSeparator.height: 0)
	property alias replyRightMargin: replyPreview.rightMargin
	property alias replyLeftMargin: replyPreview.leftMargin
	spacing: 0
	Layout.preferredHeight: fitHeight
	Layout.maximumHeight: fitHeight> maxHeight ? maxHeight : fitHeight	// ?? just using maxHeight doesn't work.
	function hide(){
	}
	function addFile(path){
		filesPreview.addFile(path)
	}
	ChatReplyPreview{
		id: replyPreview
		Layout.fillWidth: true
		maxHeight: parent.maxHeight - (audioPreview.visible ? audioPreview.height + audioSeparator.height: 0)
								- (filesPreview.visible ? filesPreview.height + filesSeparator.height: 0)
	}
	Item{
		id: replySeparator
		visible: replyPreview.visible
		Layout.preferredHeight: visible ? ChatStyle.separatorHeight : 0
		Layout.fillWidth: true
	}
	ChatAudioPreview{
		id: audioPreview
		Layout.fillWidth: true
	}
	Item{
		id: audioSeparator
		visible: audioPreview.visible
		Layout.preferredHeight: visible ? ChatStyle.separatorHeight : 0
		Layout.fillWidth: true
	}
	ChatFilePreview{
		id: filesPreview
		Layout.fillWidth: true
	}
	Item{
		id: filesSeparator
		visible: filesPreview.visible
		Layout.preferredHeight: visible ? ChatStyle.separatorHeight : 0
		Layout.fillWidth: true
	}
}	