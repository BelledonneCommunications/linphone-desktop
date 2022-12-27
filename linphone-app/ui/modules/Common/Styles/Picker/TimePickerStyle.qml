pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'TimePicker'
	property var hoursColor: ColorsList.add(sectionName+'_hours', 'i')
	property var minutesColor: ColorsList.add(sectionName+'_minutes', 'i')
	property var selectedItemColor: ColorsList.add(sectionName+'_selected', 'l')
	property var unselectedItemColor: ColorsList.add(sectionName+'_unselected', 'g')
	
}
