pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'DropDownStaticMenu'
	property int spacing: 1
	
	property QtObject entry: QtObject {
		property int leftMargin: 18
		property int rightMargin: 8
		
		property QtObject color: QtObject {
			property var hovered: ColorsList.add(sectionName+'_entry_h', 'j')
			property var normal: ColorsList.add(sectionName+'_entry_n', 'g')
			property var pressed: ColorsList.add(sectionName+'_entry_p', 'i')
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_entry_text', 'q')
			property int pointSize: Units.dp * 9
		}
	}
}
