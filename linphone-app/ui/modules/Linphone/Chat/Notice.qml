import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

RowLayout{
	property string _type: {
		var status = $chatEntry.status
		
		if (status === ChatRoomModel.NoticeMessage) {
			return 'message';
		}
		if (status === ChatRoomModel.NoticeError) {
			return 'error';
		}
		return 'unknown_notice'
	}
	
	Layout.preferredHeight: ChatStyle.entry.lineHeight
	spacing: ChatStyle.entry.message.extraContent.spacing
	Rectangle{
		height:1
		Layout.fillWidth: true
		color:( $chatEntry.status == ChatRoomModel.NoticeError ? 'red' : 'black' )
	}
	
	Text {
		Layout.preferredWidth: contentWidth
		id:message
		color:( $chatEntry.status == ChatRoomModel.NoticeError ? 'red' : 'black' )
		font {
			bold: true
			pointSize: ChatStyle.entry.event.text.pointSize
		}
		height: parent.height
		text: $chatEntry.name?$chatEntry.message.arg($chatEntry.name):$chatEntry.message
		verticalAlignment: Text.AlignVCenter
		TooltipArea {
		  text: $chatEntry.timestamp.toLocaleString(Qt.locale(App.locale))
		}
	}
	Rectangle{
		height:1
		Layout.fillWidth: true
		color:( $chatEntry.status == ChatRoomModel.NoticeError ? 'red' : 'black' )
	}
}
