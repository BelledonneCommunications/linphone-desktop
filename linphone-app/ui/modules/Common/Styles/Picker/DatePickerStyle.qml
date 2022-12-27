pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'DatePicker'
	
	property QtObject title: QtObject{
		property var colorModel: ColorsList.add(sectionName+'_title_fg', 'g')	
		property real pointSize: Units.dp * 11
	}
	property QtObject cell: QtObject{
		property var colorModel: ColorsList.add(sectionName+'_cell_fg', 'g')
		property var selectedBorderColor: ColorsList.add(sectionName+'_selected', 'i')
		property real selectedPointSize: Units.dp * 14
		property real dayHeaderPointSize: Units.dp * 12
		property real dayPointSize: Units.dp * 11
	}
	
	property QtObject nextMonthButton: QtObject {
		property int iconSize: 20
		property string name : 'nextMonth'
		property string icon : 'panel_arrow_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 'l_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 'l_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 'l_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 'l_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 'l_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 'l_p_b_fg')
	}
}
