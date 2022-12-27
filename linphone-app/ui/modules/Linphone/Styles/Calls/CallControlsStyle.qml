pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CallControl'
	property var colorModel: ColorsList.add(sectionName, 'e')
	property int height: 60
	property int leftMargin: 12
	property int rightMargin: 12
	property int signSize: 40
}
