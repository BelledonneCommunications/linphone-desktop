pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property QtObject entry: QtObject {
		
		property QtObject status: QtObject {
			property color color : ColorsList.add("Participants_entry_status", "g").color
			property int pointSize : Units.dp * 8
		}
	}
}
