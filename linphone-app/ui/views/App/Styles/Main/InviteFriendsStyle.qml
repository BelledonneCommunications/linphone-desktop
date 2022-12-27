pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'InviteFriends'
	property var colorModel: ColorsList.add(sectionName+'_bg', 'k')
	property int width: 400
	
	property QtObject message: QtObject {
		property int height: 140
	}
	
	property QtObject buttons: QtObject {
		property int bottomMargin: 35
		property int spacing: 10
	}
}
