pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
	property QtObject background : QtObject {
		property color color: Colors.g20
		property int radius : 10
	}
	
	property QtObject contentItem: QtObject {
		property int implicitHeight: 8
		property int implicitWidth: 8
		property int radius: 10
	}
	
	property QtObject color: QtObject {
		property color hovered: Colors.h
		property color normal: Colors.g20
		property color pressed: Colors.d
	}
}
