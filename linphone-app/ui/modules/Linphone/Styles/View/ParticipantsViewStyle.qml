pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
	property QtObject entry: QtObject {
		
		property QtObject status: QtObject {
			property color color : Colors.g.color
			property int pointSize : Units.dp * 8
		}
	}
}
