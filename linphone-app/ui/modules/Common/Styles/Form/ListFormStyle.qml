pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property int lineHeight: 35
	property string sectionName : 'ListForm'
	property QtObject value: QtObject {
		property QtObject placeholder: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_placeholder', 'n')
			property int pointSize: Units.dp * 10
		}
		
		property QtObject text: QtObject {
			property int padding: 10
		}
	}
	
	property QtObject titleArea: QtObject  {
		property int spacing: 10
		property int iconSize: 18
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_text', 'j')
			property int pointSize: Units.dp * 9
			property int width: 130
		}
		property QtObject add: QtObject {
			property int iconSize: 18
			property string name : 'add'
			property string icon : 'add_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
			property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'l_d_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
			property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'l_d_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
			
		}
	}
}
