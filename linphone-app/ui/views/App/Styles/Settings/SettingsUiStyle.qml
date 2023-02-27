pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName : 'SettingsUi'
	property QtObject options: QtObject {
			property int iconSize: 25
			property string icon : 'options_custom'
			property string name : 'options'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
		}
	property QtObject cancel: QtObject {
		property int iconSize: 25
		property string icon : 'cancel_custom'
		property string name : 'cancel'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
	}
}
