pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CheckBox'
	property int pointSize: Units.dp * 10
	property int radius: 3
	property int size: 18
	
	property QtObject color: QtObject {
		property var pressed:  ColorsList.add(sectionName+'_p', 'i')
		property var hovered: ColorsList.add(sectionName+'_h', 'h')
		property var normal: ColorsList.add(sectionName+'_n', 'g')
		property var selected:  ColorsList.add(sectionName+'_u', 'i')
	}
}
