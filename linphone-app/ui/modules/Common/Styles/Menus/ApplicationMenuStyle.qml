pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ApplicationMenu'
	property int spacing: 1
	property var backgroundColor: ColorsList.add(sectionName+'_bg', 'n')
	
	property QtObject entry: QtObject {
		property int iconSize: 24
		property int leftMargin: 20
		property int rightMargin: 20
		property int spacing: 18
		
		property QtObject color: QtObject {
			property var hovered: ColorsList.add(sectionName+'_entry_h', 'h')
			property var normal: ColorsList.add(sectionName+'_entry_n', 'g')
			property var pressed: ColorsList.add(sectionName+'_entry_p', 'i')
			property var selected: ColorsList.add(sectionName+'_entry_selected', 'j')
		}
		
		property QtObject indicator: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_entry_indicator', 'i')
			property int width: 5
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_entry_text_n', 'q')
				property var selected: ColorsList.add(sectionName+'_entry_text_c', 'q')
			}
		}
	}
}
