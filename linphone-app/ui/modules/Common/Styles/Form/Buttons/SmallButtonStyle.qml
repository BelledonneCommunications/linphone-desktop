pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'SmallButton'
	property int leftPadding: 5
	property int rightPadding: 5
	
	property QtObject background: QtObject {
		property int height: 22
		property int radius: 20
		
		property QtObject color: QtObject {
			property color hovered: ColorsList.add(sectionName+'_bg_h', 'c').color
			property color normal: ColorsList.add(sectionName+'_bg_n', 'f').color
			property color pressed: ColorsList.add(sectionName+'_bg_p', 'i').color
		}
	}
	
	property QtObject text: QtObject {
		property color color: ColorsList.add(sectionName+'_text', 'q').color
		property int pointSize: Units.dp * 8
	}
}
