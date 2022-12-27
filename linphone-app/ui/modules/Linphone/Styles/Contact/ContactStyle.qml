pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Contact'
	property int contentHeight: 32
	property int height: 50
	property int leftMargin: 14
	property int rightMargin: 14
	property int spacing: 14
	
	property QtObject groupChat: QtObject {
		property string icon: 'chat_room_custom'
		property var colorModel: ColorsList.addImageColor(sectionName+'_groupChat', icon, 'g')
		property var avatarColor: ColorsList.addImageColor(sectionName+'_groupChat_onAvatar', icon, 'q')
		property var avatarDarkModeColor: ColorsList.addImageColor(sectionName+'_groupChat_dark_onAvatar', icon, 'd')
	}
}
