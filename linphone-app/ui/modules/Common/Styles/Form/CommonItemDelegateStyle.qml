pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CommonItemDelegate'
	property QtObject color: QtObject {
		property color hovered: ColorsList.add(sectionName+'_h', 'o').color
		property color normal: ColorsList.add(sectionName+'_n', 'q').color
	}
	
	property QtObject contentItem: QtObject {
		property int iconSize: 20
		property int spacing: 5
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_text', 'd').color
			property int pointSize: Units.dp * 10
		}
	}
	
	property QtObject indicator: QtObject {
		property color color: ColorsList.add(sectionName+'_indicator', 'i').color
		property int width: 5
	}
	
	property QtObject separator: QtObject {
		property color color: ColorsList.add(sectionName+'_separator', 'c').color
		property int height: 1
	}
}
