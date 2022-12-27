pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TransparentTextInput'
	property var backgroundColor: ColorsList.add(sectionName+'_bg', 'f')
	property int iconSize: 12
	property int padding: 10
	
	property QtObject placeholder: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_palceholder', 'n')
		property int pointSize: Units.dp * 10
	}
	
	property QtObject text: QtObject {
		property int pointSize: Units.dp * 10
		
		property QtObject color: QtObject {
			property var focused: ColorsList.add(sectionName+'_text_focused', 'l')
			property var normal: ColorsList.add(sectionName+'_text_n', 'd')
		}
	}
}
