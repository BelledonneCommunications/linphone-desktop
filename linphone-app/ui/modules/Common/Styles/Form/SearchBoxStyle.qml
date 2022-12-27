pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'SearchBox'
	property var shadowColor: ColorsList.add(sectionName+'_shadow', 'l')
	property var iconColor: ColorsList.add(sectionName+'_icon', 'c')
	property string searchIcon: 'search_custom'
	property string cancelIcon: 'close_custom'
}
