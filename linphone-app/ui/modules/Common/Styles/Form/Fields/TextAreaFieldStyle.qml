pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TextAreaField'
	property QtObject background: QtObject {
		property int height: 36
		property int width: 200
		
		property int radius: 4
		
		property QtObject border: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_bg_border', 'c')
			property int width: 1
		}
		
		property QtObject color: QtObject {
			property var normal: ColorsList.add(sectionName+'_bg_n', 'q')
			property var readOnly: ColorsList.add(sectionName+'_bg_readOnly', 'e')
		}
	}
	
	property QtObject text: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_text', 'd')
		property int pointSize: Units.dp * 10
		property int padding: 8
	}
}
