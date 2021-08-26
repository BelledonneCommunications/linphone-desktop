pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
	property QtObject backgroundColor: QtObject {
		property color disabled: Colors.o.color
		property color hovered: Colors.j.color
		property color normal: Colors.r.color
		property color pressed: Colors.i.color
	}
	
	property QtObject textColor: QtObject {
		property color disabled: Colors.q.color
		property color hovered: Colors.q.color
		property color normal: Colors.q.color
		property color pressed: Colors.q.color
	}
	property QtObject borderColor : backgroundColor
}
