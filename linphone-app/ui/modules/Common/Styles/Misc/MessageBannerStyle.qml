pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'MessageBanner'
	
	property string copyTextIcon : 'copy_custom'
	property color color: ColorsList.add(sectionName+'_message_banner', '', 'Background of message banner', '#9ecd1d').color
	property color textColor: ColorsList.add(sectionName+'_message_banner_text', 'q', 'Text of message banner').color
	property int pointSize: Units.dp * 9
}
