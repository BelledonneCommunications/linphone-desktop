pragma Singleton
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'Recordings'
	
	property QtObject title: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_title', 'j')
		property int pointSize: Units.dp * 12
	}
	
	property QtObject filename: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_filename', 'j')
		property int pointSize: Units.dp * 10
	}
		
	property QtObject buttons: QtObject {
		property int size: 40
		property QtObject play: QtObject {
			property int iconSize: buttons.size
			property string name : 'play'
			property string icon : 'chat_audio_play_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_inv_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_inv_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_inv_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_inv_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_inv_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_inv_fg')
		}
		property QtObject pause: QtObject {
			property int iconSize: buttons.size
			property string name : 'pause'
			property string icon : 'chat_audio_pause_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_inv_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_inv_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_inv_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_inv_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_inv_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_inv_fg')
		}
		property QtObject remove: QtObject {
			property int iconSize: buttons.size
			property string name : 'delete'
			property string icon : 'delete_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		}
		property QtObject openImage: QtObject {
			property int iconSize: buttons.size/2
			property string name : 'openImage'
			property string icon : 'file_image_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_inv_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_inv_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_inv_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_inv_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_inv_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_inv_fg')
		}
		property QtObject openFile: QtObject {
			property int iconSize: buttons.size/2
			property string name : 'openFile'
			property string icon : 'file_extension_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_inv_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_inv_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_inv_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_inv_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_inv_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_inv_fg')
		}
	}
}
