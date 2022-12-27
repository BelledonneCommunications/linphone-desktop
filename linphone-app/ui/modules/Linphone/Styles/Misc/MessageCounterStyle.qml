pragma Singleton
import QtQml 2.2

import Units 1.0

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'MessageCounter'
	property QtObject iconSize: QtObject {
		property int amount: 12
		property int message: 18
	}
	
	property QtObject text: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_text', 'q')
		property int pointSize: Units.dp * 6
	}
}
