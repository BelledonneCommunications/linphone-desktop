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
	property alias replyChatMessageModel : replyPreview.replyChatMessageModel
	property int maxHeight: parent.height
	anchors.left: parent.left
	anchors.right: parent.right
	anchors.bottom: parent.bottom
	height: replyPreview.height
	
	ChatReplyPreview{
		id: replyPreview
		Layout.fillWidth: true
	}
}	