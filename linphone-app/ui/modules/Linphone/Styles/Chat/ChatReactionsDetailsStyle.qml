pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatReactionsDetails'
	property var backgroundColorModel: ColorsList.add(sectionName+'_bg', 'l50')
	property var stickerColorModel: ColorsList.add(sectionName+'_sticker_bg', 'k')
	property var separatorColorModel: ColorsList.add(sectionName+'_separator', 'f')
	
	property QtObject tabBar: QtObject{
		property int pointSize: Units.dp * 11
	}
}
