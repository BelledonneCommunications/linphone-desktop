pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'SettingsAudio'
	
	property color sliderBackgroundColor: ColorsList.add(sectionName+'_slider_bg', 'slider_bg').color
	property color sliderHighColor: ColorsList.add(sectionName+'_slider_high', 'slider_high').color
	property color sliderLowColor: ColorsList.add(sectionName+'_slider_low', 'slider_low').color
	
	property QtObject ringPlayer: QtObject {
		property int leftMargin: 10
	}
	property QtObject warningMessage: QtObject {
		property int iconSize: 20
	}
	property QtObject pause: QtObject {
		property int iconSize: 40
		property string icon : 'pause_custom'
		property string name : 'pause'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		property color foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 's_p_b_fg').color
	}
	property QtObject play: QtObject {
		property int iconSize: 40
		property string icon : 'play_custom'
		property string name : 'play'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		property color foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 's_p_b_fg').color
	}
}
