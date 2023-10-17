pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'MenuSeparator'
		property var colorModel: ColorsList.add(sectionName+'_n', 'u')
		property int topPadding: 0
		property int bottomPadding: 0
		property int height : 1
}
