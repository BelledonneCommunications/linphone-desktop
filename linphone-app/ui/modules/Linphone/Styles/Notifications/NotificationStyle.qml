pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Notification'
	property var colorModel: ColorsList.add(sectionName, 'k')
	property int height: 120
	property int iconSize: 40
	property int width: 300
	
	property QtObject border: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_border', 'n')
		property int width: 1
	}
}
