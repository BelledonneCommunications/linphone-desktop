pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
	property QtObject background : QtObject {
		property color color: Colors.g20.color
		property int radius : 10
	}
	
	property QtObject contentItem: QtObject {
		property int implicitHeight: 8
		property int implicitWidth: 8
		property int radius: 10
	}
	
	property QtObject color: QtObject {
		property color hovered: Colors.h.color
		property color normal: Colors.g20.color
		property color pressed: Colors.d.color
	}
}
