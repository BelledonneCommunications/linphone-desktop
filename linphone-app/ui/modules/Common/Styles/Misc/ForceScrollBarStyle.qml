pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property QtObject background : QtObject {
		property color color:  ColorsList.add("ForceScrollBar_background", "g20").color
		property int radius : 10
	}
	
	property QtObject contentItem: QtObject {
		property int implicitHeight: 8
		property int implicitWidth: 8
		property int radius: 10
	}
	
	property QtObject color: QtObject {
		property color hovered: ColorsList.add("ForceScrollBar_hovered", "h").color
		property color normal: ColorsList.add("ForceScrollBar_normal", "g20").color
		property color pressed: ColorsList.add("ForceScrollBar_pressed", "d").color
	}
}
