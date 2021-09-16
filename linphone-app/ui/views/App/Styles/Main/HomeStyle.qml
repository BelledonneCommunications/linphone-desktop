pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Home'
	property color color: ColorsList.add(sectionName+'_bg', 'k').color
	property int spacing: 20
}
