pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatAudioMessage'
	property int minWidth: 500
	property int emptySpace: 10
	property color color: ColorsList.add(sectionName, 'q').color
	
	property color backgroundColor: ColorsList.add(sectionName+'_bg', 'a').color
	
	property QtObject pauseAction: QtObject {
		property int iconSize: 25
		property string name : 'pause'
		property string icon : 'chat_audio_pause_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'q').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'q').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'q').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
	property QtObject playAction: QtObject {
		property int iconSize: 25
		property string name : 'play'
		property string icon : 'chat_audio_play_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'q').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'q').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'q').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
	
	property QtObject progressionWave: QtObject{
		property int iconSize: 60
		property int iconHeight: 60
		property int iconWidth: 60
		property string name : 'progression_soundwave'
		property string icon : 'chat_audio_soundwave_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'w_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'w_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'w_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'w_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'w_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'w_p_b_fg').color
		
		property color backgroundHiddenPartNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_n', icon, 'l_h_b_bg').color
		property color backgroundHiddenPartHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_h', icon, 'l_n_b_bg').color
		property color backgroundHiddenPartPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_bg_p', icon, 'l_p_b_bg').color
		
		property color foregroundHiddenPartNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_n', icon, 'l_h_b_fg').color
		property color foregroundHiddenPartHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_h', icon, 'l_n_b_fg').color
		property color foregroundHiddenPartPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_hidden_fg_p', icon, 'l_p_b_fg').color
	}
	
	property int padding: 8
}
