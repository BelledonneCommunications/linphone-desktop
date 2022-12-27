pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'MessageBanner'
	
	property string copyTextIcon : 'menu_copy_text_custom'
	property var colorModel: ColorsList.add(sectionName+'_message_banner', 'message_banner_bg', 'Background of message banner')
	property var textColor: ColorsList.add(sectionName+'_message_banner_text', 'message_banner_fg', 'Text of message banner')
	property int pointSize: Units.dp * 9
}
