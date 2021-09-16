pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Assistant'
	property QtObject buttons: QtObject {
		property int spacing: 10
	}
	
	property QtObject content: QtObject {
		property int height: 375
		property int width: 400
	}
	
	property QtObject info: QtObject {
		property int spacing: 20
		
		property QtObject description: QtObject {
			property color color: ColorsList.add(sectionName+'_info_description', 'g').color
			property int pointSize: Units.dp * 11
		}
		
		property QtObject title: QtObject {
			property color color: ColorsList.add(sectionName+'_info_title', 'g').color
			property int pointSize: Units.dp * 11
		}
	}
}
