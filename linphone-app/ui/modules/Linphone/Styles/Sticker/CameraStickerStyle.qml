pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'CameraSticker'
	property color cameraBackgroundColor: ColorsList.add(sectionName+'_camera_bg', 'fullscreen_conference_bg').color
	property int radius : 10
}
