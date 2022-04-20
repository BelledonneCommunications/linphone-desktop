pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'CameraView'
	property color backgroundColor: ColorsList.add(sectionName+'_description', '', '', '#798791').color
	property int radius : 8
	
	property QtObject contactDescription: QtObject {
		property color color: ColorsList.add(sectionName+'_username', 'q').color
		property int pointSize: Units.dp * 12
		property int weight: Font.Bold
	}
	
	//------------------------------------------------------------------------------
	property QtObject closePreview: QtObject {
		property int iconSize: 40
		property string icon : 'close_custom'
		property string name : 'close_preview'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_inv_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_inv_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg').color
	}
	//------------------------------------------------------------------------------
	
}
