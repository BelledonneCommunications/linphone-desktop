pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'FileView'

	property QtObject progression: QtObject{
		property int iconSize: 60
		property int iconHeight: 60
		property int iconWidth: 60
		property string name : 'progression'
		property string icon : ''
		
		property var backgroundColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 'c80')
		
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'w_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'w_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'w_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'w_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'w_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'w_p_b_fg')
		
		property var backgroundHiddenPartNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_n', icon, 'l_n_b_bg')
		property var backgroundHiddenPartHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_h', icon, 'l_h_b_bg')
		property var backgroundHiddenPartPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_p', icon, 'l_p_b_bg')
		
		property var foregroundHiddenPartNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_n', icon, 'l_n_b_fg')
		property var foregroundHiddenPartHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_h', icon, 'l_h_b_fg')
		property var foregroundHiddenPartPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_p', icon, 'l_p_b_fg')
	}
	
	property QtObject pauseAction: QtObject {
		property int iconSize: 25
		property string name : 'pause'
		property string icon : 'chat_audio_pause_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg')
	}
	property QtObject playAction: QtObject {
		property int iconSize: 25
		property string name : 'play'
		property string icon : 'chat_audio_play_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg')
	}
	
	property QtObject speakerOn: QtObject {
		property int iconSize: 25
		property string icon : 'speaker_on_custom'
		property string name : 'speakerOn'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg')
	}
	property QtObject speakerOff: QtObject {
		property int iconSize: 25
		property string icon : 'speaker_off_custom'
		property string name : 'speakerOff'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg')
	}
	property QtObject exportFile: QtObject{
		property string icon: 'download_custom'
		property string name : 'exportFile'
		property int height: 20
		property int pointSize: Units.dp * 8
		property int iconSize: 25
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg')
	}
	property QtObject extension: QtObject {
		property string icon:  'file_extension_custom'
		property int iconSize: 60
	}
}