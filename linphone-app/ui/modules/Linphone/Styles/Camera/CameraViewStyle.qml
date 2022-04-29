pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'CameraView'
	property color outBackgroundColor: ColorsList.add(sectionName+'_out_bg', 'conference_out_avatar_bg').color
	property color inAvatarBackgroundColor: ColorsList.add(sectionName+'_in_bg', 'conference_bg').color
	
	property int radius : 10
	
	property QtObject contactDescription: QtObject {
		property color color: ColorsList.add(sectionName+'_username', 'q').color
		property int pointSize: Units.dp * 12
		property int weight: Font.Bold
	}
	
	property QtObject border: QtObject {
		property color color: ColorsList.add(sectionName+'_border', 'b').color
		property int width: 2
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
	property QtObject pauseView: QtObject{
		property color backgroundColor : ColorsList.add(sectionName+'_pauseView_bg_n', 'l').color
		property QtObject button: QtObject {
			property int iconSize: 80
			property string icon : 'pause_custom'
			property string name : 'pause'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 's_n_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg', icon, 's_n_b_fg').color
		}
	}
	property QtObject isMuted: QtObject{
		property color backgroundColor : ColorsList.add(sectionName+'_isMuted_bg', 'l').color
		property QtObject button: QtObject {
			property int iconSize: 40
			property string icon : 'micro_off_custom'
			property string name : 'isMuted'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg', icon, 's_d_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg', icon, 's_d_b_fg').color
		}
	}
}
