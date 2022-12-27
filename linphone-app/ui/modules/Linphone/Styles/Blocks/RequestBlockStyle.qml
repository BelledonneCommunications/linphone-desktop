pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'RequestBlock'
	property int height: 80
	
	property QtObject error: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_error', 'error')
		property int pointSize: Units.dp * 11
		property int padding: 4
	}
	
	property QtObject loadingIndicator: QtObject {
		property int height: 20
		property int width: 20
	}
}
