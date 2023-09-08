pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CallTimeline'
	property var colorModel: ColorsList.add(sectionName+'_bg', 'd')
	property QtObject backgroundColor: QtObject {
			property var normal: ColorsList.add(sectionName+'_legend_bg_n', 'timeline_header_bg')
	}
	property int pointSize: Units.dp * 11
	property QtObject searchField: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_searchField', 'c')
		property int pointSize: Units.dp * 9
	}
	
	property QtObject filterAction: QtObject {
		property int iconSize: 30
		property string name : 'filter'
		property string icon : 'filter_params_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
		property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'me_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'me_p_b_fg')
	}
}
