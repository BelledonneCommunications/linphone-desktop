pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'TelKeypad'
	property int columnSpacing: 0
	property int height: 180
	property int rowSpacing: 0
	property int width: 180
	property color color: ColorsList.add(sectionName+'', 'k').color
	property color selectedColor : ColorsList.add(sectionName+'_c', 'm').color
	property int selectedBorderWidth: 2
	property real radius : 5.0
	
	property QtObject button: QtObject {
		property QtObject color: QtObject {
			property color normal: ColorsList.add(sectionName+'_b_n', 'q').color
			property color pressed: ColorsList.add(sectionName+'_b_p', 'i').color
		}
		
		property QtObject line: QtObject {
			property color color: ColorsList.add(sectionName+'_b_line', 'l50').color
			property int bottomMargin: 4
			property int height: 2
			property int leftMargin: 8
			property int rightMargin: 8
			property int topMargin: 0
		}
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_b_text', 'd').color
			property int pointSize: Units.dp * 11
		}
	}
}
