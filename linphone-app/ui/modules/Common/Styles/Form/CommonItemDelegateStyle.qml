pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CommonItemDelegate'
	property QtObject color: QtObject {
		property var hovered: ColorsList.add(sectionName+'_h', 'o')
		property var normal: ColorsList.add(sectionName+'_n', 'q')
	}
	
	property QtObject contentItem: QtObject {
		property int iconSize: 20
		property int spacing: 5
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_text', 'd')
			property int pointSize: Units.dp * 10
		}
	}
	
	property QtObject indicator: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_indicator', 'i')
		property int width: 5
	}
	
	property QtObject separator: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_separator', 'c')
		property int height: 1
	}
}
