pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Menu'
	property QtObject normal : QtObject {
		property var colorModel: ColorsList.add(sectionName+'_n', 'q')
		property int width: 130
		property bool shadowEnabled: true
		property int radius : 0
		
		property QtObject border : QtObject {
			property var colorModel: {'color': 'black'}
			property int width: 0
		}
	}
	property QtObject aux : QtObject {
		property var colorModel: ColorsList.add(sectionName+'_aux', 'q')
		property int width: 200
		property bool shadowEnabled: false
		property int radius : 5
		
		property QtObject border : QtObject {
			property var colorModel: ColorsList.add(sectionName+'_aux_border', 'u')
			property int width: 1
		}
	}
	property QtObject aux2 : QtObject {
		property var colorModel: ColorsList.add(sectionName+'_aux2', 'q')
		property int width: 250
		property bool shadowEnabled: false
		property int radius : 0
		
		property QtObject border : QtObject {
			property var colorModel: {'color':'black'}
			property int width: 0
		}
	}
}
