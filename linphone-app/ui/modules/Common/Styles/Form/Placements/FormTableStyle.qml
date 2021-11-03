pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'FormTable'
	property int spacing: 10
	
	property QtObject entry: QtObject {
		property int height: 36
		property int width: 200
		property int maxWidth: 400
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_entry_text', 'j').color
			property int pointSize: Units.dp * 10
		}
	}
}
