pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName : 'SettingsAdvanced'
	property QtObject buttons: QtObject {
		property int spacing: 10
	}
	
	property QtObject error: QtObject {
		property color color: ColorsList.add(sectionName+'_error', 'error').color
	}
	property QtObject info: QtObject {
		property color color: ColorsList.add(sectionName+'_info', 'j').color
		property int pointSize: Units.dp * 11
	}
	property QtObject lists: QtObject {
		property int spacing: 20
		property real iconScale : 0.8
		property int margin: 10
	}
	property QtObject add: QtObject {
		property int iconSize: 35
		property string name : 'add'
		property string icon : 'add_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'me_d_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'me_d_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
	property QtObject cancel: QtObject {
		property int iconSize: 35
		property string icon : 'cancel_custom'
		property string name : 'cancel'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject options: QtObject {
			property int iconSize: 35
			property string icon : 'options_custom'
			property string name : 'options'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
			property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
			property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		}
}
