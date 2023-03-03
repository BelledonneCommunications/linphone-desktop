pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatReplyMessage'
	property var colorModel: ColorsList.add(sectionName, 'q')
	property QtObject header: QtObject{
		property var colorModel: ColorsList.add(sectionName+'_header', 'h')
		property int pointSizeOffset: -3
		property QtObject replyIcon: QtObject{
			property string icon : 'menu_reply_custom'
			property int iconSize: 22
		}
	}
	property QtObject replyArea: QtObject{
		property var outgoingMarkColor: ColorsList.add(sectionName+'_reply_outgoing_mark', 'outgoing_reply_mark_bg')
		property var incomingMarkColor: ColorsList.add(sectionName+'_reply_incoming_mark', 'incoming_reply_mark_bg')
		property var backgroundColor: ColorsList.add(sectionName+'_reply_bg', 'q')
		property var foregroundColor: ColorsList.add(sectionName+'_reply_fg', 'h')
		property var fileBackgroundColor: ColorsList.add(sectionName+'_reply_file_bg', 'reply_file_bg')
		property int usernamePointSizeOffset: -2
		property int pointSizeOffset: -2
		
	}
	
	property int padding: 8
	
}
