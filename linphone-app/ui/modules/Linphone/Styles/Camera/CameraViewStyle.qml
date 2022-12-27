pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'CameraView'
	property var outBackgroundColor: ColorsList.add(sectionName+'_out_bg', 'conference_out_avatar_bg')
	property var inAvatarBackgroundColor: ColorsList.add(sectionName+'_in_bg', 'conference_bg')
	property var cameraBackgroundColor: ColorsList.add(sectionName+'_camera_bg', 'fullscreen_conference_bg')
	
	property int radius : 10
	
	property QtObject contactDescription: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_username', 'q')
		property int pointSize: Units.dp * 12
		property int weight: Font.Bold
	}
	
	property QtObject border: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_border', 'b')
		property int width: 2
	}
	
	
	//------------------------------------------------------------------------------
	property QtObject closePreview: QtObject {
		property int iconSize: 40
		property string icon : 'close_custom'
		property string name : 'close_preview'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_inv_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_inv_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg')
	}
	//------------------------------------------------------------------------------
	property QtObject pauseView: QtObject{
		property var backgroundColor : ColorsList.add(sectionName+'_pauseView_bg_n', 'l')
		property QtObject button: QtObject {
			property int iconSize: 80
			property string icon : 'pause_custom'
			property string name : 'pause'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 's_n_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg', icon, 's_n_b_fg')
		}
	}
	property QtObject isMuted: QtObject{
		property var backgroundColor : ColorsList.add(sectionName+'_isMuted_bg', 'j')
		property QtObject button: QtObject {
			property int iconSize: 30
			property string icon : 'micro_off_custom'
			property string name : 'isMuted'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 's_d_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg', icon, 's_d_b_fg')
		}
	}
	property QtObject isAudioOnly: QtObject{
		property var backgroundColor : ColorsList.add(sectionName+'_isAudioOnly_bg', 'j')
		property QtObject button: QtObject {
			property int iconSize: 30
			property string icon : 'conference_audio_only_custom'
			property string name : 'isAudioOnly'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 's_d_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg', icon, 's_d_b_fg')
		}
	}
}
