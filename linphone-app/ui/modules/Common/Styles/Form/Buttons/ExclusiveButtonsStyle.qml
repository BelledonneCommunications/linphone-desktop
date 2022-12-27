pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'ExclusiveButtons'
	property int buttonsSpacing: 8
	
	property QtObject button: QtObject {
		property QtObject color: QtObject {
			property var hovered: ColorsList.add(sectionName+'_h', 'n')
			property var normal: ColorsList.add(sectionName+'_n', 'x')
			property var pressed: ColorsList.add(sectionName+'_p', 'i')
			property var selected: ColorsList.add(sectionName+'_c', 'g')
		}
	}
}
