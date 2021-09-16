pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ApplicationMenu'
	property int spacing: 1
	property color backgroundColor: ColorsList.add(sectionName+'_bg', 'n').color
	
	property QtObject entry: QtObject {
		property int iconSize: 24
		property int leftMargin: 20
		property int rightMargin: 20
		property int spacing: 18
		
		property QtObject color: QtObject {
			property color hovered: ColorsList.add(sectionName+'_entry_h', 'h').color
			property color normal: ColorsList.add(sectionName+'_entry_n', 'g').color
			property color pressed: ColorsList.add(sectionName+'_entry_p', 'i').color
			property color selected: ColorsList.add(sectionName+'_entry_selected', 'j').color
		}
		
		property QtObject indicator: QtObject {
			property color color: ColorsList.add(sectionName+'_entry_indicator', 'i').color
			property int width: 5
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_entry_text_n', 'q').color
				property color selected: ColorsList.add(sectionName+'_entry_text_c', 'q').color
			}
		}
	}
}
