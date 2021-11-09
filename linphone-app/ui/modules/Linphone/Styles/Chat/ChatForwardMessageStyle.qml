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
		property QtObject forwardIcon: QtObject{
			property string icon : 'menu_forward_custom'
			property int iconSize: 22
		}
	}
		
	property int padding: 8
	
}
