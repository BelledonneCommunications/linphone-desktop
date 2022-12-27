pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Paned'
	property int transitionDuration: 200
	
	property QtObject handle: QtObject {
		property int width: 5
		
		property QtObject color: QtObject {
			property var hovered: ColorsList.add(sectionName+'_hovered', 'h')
			property var normal: ColorsList.add(sectionName+'_normal', 'c')
			property var pressed: ColorsList.add(sectionName+'_pressed', 'd')
		}
	}
}
