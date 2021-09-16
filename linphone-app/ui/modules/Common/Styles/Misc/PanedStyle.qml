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
			property color hovered: ColorsList.add(sectionName+'_hovered', 'h').color
			property color normal: ColorsList.add(sectionName+'_normal', 'c').color
			property color pressed: ColorsList.add(sectionName+'_pressed', 'd').color
		}
	}
}
