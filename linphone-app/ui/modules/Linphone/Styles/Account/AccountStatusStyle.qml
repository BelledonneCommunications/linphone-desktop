pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'AccountStatus'
	property int horizontalSpacing: 8
	property int verticalSpacing: 2
	property var busyColor: ColorsList.add(sectionName+'_spinner', 'i')
	
	property QtObject presenceLevel: QtObject {
		property int bottomMargin: 1
		property int size: 16
	}
	
	property QtObject sipAddress: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_sipAddress', 'g')
		property int pointSize: Units.dp * 10
	}
	
	property QtObject username: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_username', 'j')
		property int pointSize: Units.dp * 11
	}
	property QtObject messageCounter: QtObject {
		property int bottomMargin: 4
		property int size: 16
	}
}
