pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TabContainer'
	property color color: ColorsList.add(sectionName+'', 'k').color
	property int bottomMargin: 30
	property int leftMargin: 30
	property int rightMargin: 40
	property int topMargin: 30
	
	property QtObject separator: QtObject {
		property int height: 2
		property color color: ColorsList.add(sectionName+'_separator', 'f').color
	}
}
