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
				property var normal: ColorsList.add(sectionName+'_n', 'f')
				property var pressed: ColorsList.add(sectionName+'_p', 'c')
			}
			
			property QtObject text: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_text', 'd')
				property int pointSize: Units.dp * 9
			}
		}
	}
}
