pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CallStats'
	property color outsideColor: ColorsList.add(sectionName+'_outside_bg', 'j50').color
	property color color: ColorsList.add(sectionName+'_bg', 'j90').color
	property int height: 280
	property int leftMargin: 12
	property int rightMargin: 12
	property int topMargin: 40
	property int spacing: 8
	property QtObject popup: QtObject{
		property int topMargin: 60
		property int bottomMargin: 100
		property int leftMargin: 110
		property int rightMargin: 110
		property int radius: 10
	}
	
	property QtObject title: QtObject {
		property color color: ColorsList.add(sectionName+'_title', 'q').color
		property int bottomMargin: 20
		property int pointSize: Units.dp * 16
	}
	
	property QtObject key: QtObject {
		property color color: ColorsList.add(sectionName+'_key', 'q').color
		property int pointSize: Units.dp * 10
		property int width: 200
	}
	
	property QtObject value: QtObject {
		property color color: ColorsList.add(sectionName+'_value', 'q').color
		property int pointSize: Units.dp * 10
	}
	property QtObject cancel: QtObject {
		property int iconSize: 40
		property string icon : 'cancel_custom'
		property string name : 'cancel'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_inv_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
}
