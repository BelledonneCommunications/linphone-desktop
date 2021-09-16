pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'NumericField'
	property QtObject tools: QtObject {
		property int width: 20
		
		property QtObject button: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_n', 'f').color
				property color pressed: ColorsList.add(sectionName+'_p', 'c').color
			}
			
			property QtObject text: QtObject {
				property color color: ColorsList.add(sectionName+'_text', 'd').color
				property int pointSize: Units.dp * 9
			}
		}
	}
}
