pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'NotificationReceivedMessage'
	property var colorModel: ColorsList.add(sectionName+'_message', 'k')
	property int bottomMargin: 15
	property int leftMargin: 15
	property int overrodeHeight: 55
	property int rightMargin: 15
	property int spacing: 0
	
	property QtObject messageContainer: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_message_container', 'o')
		property int radius: 6
		property int margins: 10
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_message_container_text', 'l')
		}
	}
}
