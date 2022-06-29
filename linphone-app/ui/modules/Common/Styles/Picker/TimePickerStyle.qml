pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'TimePicker'
	property color hoursColor: ColorsList.add(sectionName+'_hours', 'i').color
	property color minutesColor: ColorsList.add(sectionName+'_minutes', 'i').color
	property color selectedItemColor: ColorsList.add(sectionName+'_selected', 'l').color
	property color unselectedItemColor: ColorsList.add(sectionName+'_unselected', 'g').color
	
}
