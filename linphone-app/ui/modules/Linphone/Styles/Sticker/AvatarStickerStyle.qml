pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'AvatarSticker'
	property color outBackgroundColor: ColorsList.add(sectionName+'_out_bg', 'conference_out_avatar_bg').color
	property color inBackgroundColor: ColorsList.add(sectionName+'_in_bg', 'conference_bg').color
	property int radius : 10
}
