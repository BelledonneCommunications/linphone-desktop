pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatReplyMessage'
	property color color: ColorsList.add(sectionName, 'q').color
	property QtObject header: QtObject{
		property color color: ColorsList.add(sectionName+'_header', 'h').color
		property int pointSizeOffset: -3
		property QtObject replyIcon: QtObject{
			property string icon : 'menu_reply_custom'
			property int iconSize: 22
		}
	}
	property QtObject replyArea: QtObject{
		property color outgoingMarkColor: ColorsList.add(sectionName+'_reply_outgoing_mark', 'm').color
		property color incomingMarkColor: ColorsList.add(sectionName+'_reply_incoming_mark', 'r').color
		property color backgroundColor: ColorsList.add(sectionName+'_reply_bg', 'q').color
		property color foregroundColor: ColorsList.add(sectionName+'_reply_fg', 'h').color
		property int usernamePointSizeOffset: -2
		property int pointSizeOffset: -2
	}
	
	property int padding: 8
	
}
