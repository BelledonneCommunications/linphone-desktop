pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ParticipantsView'
	property QtObject entry: QtObject {
		
		property QtObject status: QtObject {
			property var colorModel : ColorsList.add(sectionName+'_entry_status', 'g')
			property int pointSize : Units.dp * 8
		}
	}
}
