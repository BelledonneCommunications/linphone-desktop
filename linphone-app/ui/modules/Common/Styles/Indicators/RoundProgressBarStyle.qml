pragma Singleton
import QtQml 2.2

import ColorsList 1.0
import Units 1.0

// =============================================================================

QtObject {
	property string sectionName: 'RoundProgressBar'
	
	property var backgroundColor:  ColorsList.add(sectionName+'_bg', 'progress_bg')
	property var progressRemainColor:  ColorsList.add(sectionName+'_remaining_fg', 'progress_remaining_fg')
	property var progressColor:  ColorsList.add(sectionName+'_fg', 'i')
	property int progressionWidth : 3
	property int borderWidth: 2
	property int pointSize:  Units.dp * 7
}
