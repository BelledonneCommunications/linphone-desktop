pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'AvatarSticker'
	property color stickerBackgroundColor: ColorsList.add(sectionName+'_out_bg', 'avatar_initials_sticker_bg').color
	property color inBackgroundColor: ColorsList.add(sectionName+'_in_bg', 'avatar_initials_bg').color
	property int radius : 10
}
