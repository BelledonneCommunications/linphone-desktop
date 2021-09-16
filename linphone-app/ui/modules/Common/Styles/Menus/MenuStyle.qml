pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Menu'
	property QtObject normal : QtObject {
		property color color: ColorsList.add(sectionName+'_n', 'q').color
		property int width: 130
		property bool shadowEnabled: true
		property int radius : 0
		
		property QtObject border : QtObject {
			property color color: 'black'
			property int width: 0
		}
	}
	property QtObject aux : QtObject {
		property color color: ColorsList.add(sectionName+'_aux', 'q').color
		property int width: 200
		property bool shadowEnabled: false
		property int radius : 5
		
		property QtObject border : QtObject {
			property color color: ColorsList.add(sectionName+'_aux_border', 'u').color
			property int width: 1
		}
	}
	property QtObject aux2 : QtObject {
		property color color: ColorsList.add(sectionName+'_aux2', 'q').color
		property int width: 250
		property bool shadowEnabled: false
		property int radius : 0
		
		property QtObject border : QtObject {
			property color color: 'black'
			property int width: 0
		}
	}
}
