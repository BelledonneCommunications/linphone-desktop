pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'ForceScrollBar'
	property QtObject background : QtObject {
		property var colorModel:  ColorsList.add(sectionName+'_bg', 'g20')
		property int radius : 10
	}
	
	property QtObject contentItem: QtObject {
		property int implicitHeight: 8
		property int implicitWidth: 8
		property int radius: 10
	}
	
	property QtObject color: QtObject {
		property var hovered: ColorsList.add(sectionName+'_h', 'h')
		property var normal: ColorsList.add(sectionName+'_n', 'g20')
		property var pressed: ColorsList.add(sectionName+'_p', 'd')
	}
}
