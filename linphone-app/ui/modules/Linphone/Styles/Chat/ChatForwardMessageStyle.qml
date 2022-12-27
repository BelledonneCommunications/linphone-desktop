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
		property QtObject forwardIcon: QtObject{
			property string icon : 'menu_forward_custom'
			property int iconSize: 22
		}
	}
		
	property int padding: 8
	
}
