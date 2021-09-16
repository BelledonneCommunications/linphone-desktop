pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'SearchBox'
	property color shadowColor: ColorsList.add(sectionName+'_shadow', 'l').color
	property color iconColor: ColorsList.add(sectionName+'_icon', 'c').color
}
