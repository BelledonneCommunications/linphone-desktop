pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'ExclusiveButtons'
	property int buttonsSpacing: 8
	
	property QtObject button: QtObject {
		property QtObject color: QtObject {
			property color hovered: ColorsList.add(sectionName+'_h', 'n').color
			property color normal: ColorsList.add(sectionName+'_n', 'x').color
			property color pressed: ColorsList.add(sectionName+'_p', 'i').color
			property color selected: ColorsList.add(sectionName+'_c', 'g').color
		}
	}
}
