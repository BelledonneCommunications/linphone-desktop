pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'ComboBox'
	property QtObject indicator: QtObject{
		property QtObject dropDown : QtObject{
			property string icon: 'drop_down_custom'
			property int iconSize: 20
			property color color: ColorsList.addImageColor(sectionName+'_indicator', icon, 'l_n_b_fg').color
		}
	 }
	property QtObject background: QtObject {
		property int height: 36
		property int iconSize: 10
		property int radius: 4
		property int width: 200
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_border_n', 'c').color
			property int width: 1
		}
		
		property QtObject color: QtObject {
			property color normal: ColorsList.add(sectionName+'_normal', 'q').color
			property color readOnly: ColorsList.add(sectionName+'_readonly', 'e').color
		}
	}
	
	property QtObject contentItem: QtObject {
		property int iconSize: 20
		property int leftMargin: 10
		property int spacing: 5
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_text_n', 'd').color
			property int pointSize: Units.dp * 10
		}
	}
}
