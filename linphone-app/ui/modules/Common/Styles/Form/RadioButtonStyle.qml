pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'RadioButton'
	property var backgroundColor: ColorsList.add(sectionName+'_bg', 'k')
	
	property int height: 60
	property var colorModel: ColorsList.add(sectionName+'_fg', 'j')
	property int weight: Font.Normal
	property int selectedWeight: Font.Bold
	property int pointSize: Units.dp * 12
}
