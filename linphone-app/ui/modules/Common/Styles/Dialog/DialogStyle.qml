pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'Dialog'
	property color color: ColorsList.add(sectionName, 'k').color
	
	property QtObject title: QtObject {
		property color lowGradient: ColorsList.add(sectionName+'_title_gradient_low', 'y').color
		property color highGradient: ColorsList.add(sectionName+'_title_gradient_high', 'z').color
	}
	
	property QtObject buttons: QtObject {
		property int bottomMargin: 30
		property int leftMargin: 50
		property int rightMargin: 50
		property int spacing: 20
		property int topMargin: 15
	}
	
	property QtObject confirmDialog: QtObject {
		property int height: 200
		property int width: 400
	}
	
	property QtObject content: QtObject {
		property int leftMargin: 25
		property int rightMargin: 25
	}
	
	property QtObject description: QtObject {
		property color color: ColorsList.add(sectionName+'_description', 'j').color
		property int leftMargin: 50
		property int pointSize: Units.dp * 11
		property int rightMargin: 50
		property int verticalMargin: 25
	}
	property QtObject closeButton: QtObject {
		property int iconSize: 20
		property string name : 'close'
		property string icon : 'close_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 'l_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 'l_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 'l_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 'l_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 'l_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 'l_p_b_fg').color
	}
}
