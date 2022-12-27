pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Home'
	property var colorModel: ColorsList.add(sectionName+'_bg', 'k')
	property int spacing: 20
}
