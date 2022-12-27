pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ContactDescription'
	property QtObject subtitle: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_subtitle', 'n')
		property int pointSize: Units.dp * 10
		property int weight: Font.Normal
	}
	
	property QtObject title: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_title', 'j')
		property int pointSize: Units.dp * 11
		property int weight: Font.Bold
		property QtObject status : QtObject{
			property var colorModel : ColorsList.add(sectionName+'_status', 'g')
			property int pointSize : Units.dp * 9
		}
	}
	
}
