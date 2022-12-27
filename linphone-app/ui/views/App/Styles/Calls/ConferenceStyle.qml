pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Conference'
	property QtObject description: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_description', 'j')
		property int pointSize: Units.dp * 12
		property int height: 60
		property int width: 150
	}
	
	property QtObject grid: QtObject {
		property int spacing: 5
		
		property QtObject cell: QtObject {
			property int height: 145
			property int spacing: 5
			property int width: 154
			
			property QtObject contactDescription: QtObject {
				property int height: 35
			}
		}
	}
	
}
