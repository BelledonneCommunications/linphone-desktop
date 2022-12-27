pragma Singleton
import QtQml 2.2

import ColorsList 1.0
import Units 1.0
// =============================================================================

QtObject {
	property string sectionName: 'UseAppSipAccount'
	property QtObject checkBox: QtObject {
		property int width: 300
	}
	property QtObject warningBlock: QtObject {
		property int spacing: 10
		property int pointSize: Units.dp * 10
		property var colorModel: ColorsList.add(sectionName+'_description', 'g')
		
		property QtObject contactUrl: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_url', 'i')
			property int pointSize: Units.dp * 9
		}
	}
}
