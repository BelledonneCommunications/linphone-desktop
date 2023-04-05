pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'EmojiPicker'
	property var backgroundColorModel: ColorsList.add(sectionName+'_bg', 'telkeypad_fg')
	property var borderColorModel: ColorsList.add(sectionName+'_border', 'telkeypad_bg')
	property int emojiSize: 26
	property int emojiMargin: 10
}
