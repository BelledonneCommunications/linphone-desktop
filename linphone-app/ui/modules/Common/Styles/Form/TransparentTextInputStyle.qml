pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TransparentTextInput'
	property color backgroundColor: ColorsList.add(sectionName+'_bg', 'f').color
	property int iconSize: 12
	property int padding: 10
	
	property QtObject placeholder: QtObject {
		property color color: ColorsList.add(sectionName+'_palceholder', 'n').color
		property int pointSize: Units.dp * 10
	}
	
	property QtObject text: QtObject {
		property int pointSize: Units.dp * 10
		
		property QtObject color: QtObject {
			property color focused: ColorsList.add(sectionName+'_text_focused', 'l').color
			property color normal: ColorsList.add(sectionName+'_text_n', 'd').color
		}
	}
}
