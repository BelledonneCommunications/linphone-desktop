pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'FileChooser'
	property QtObject tools: QtObject {
		property int width: 30
		
		property QtObject button: QtObject {
			property int iconSize: 16
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_h', 'c').color
				property color normal: ColorsList.add(sectionName+'_n', 'f').color
				property color pressed: ColorsList.add(sectionName+'_p', 'c').color
			}
		}
	}
	property QtObject file: QtObject {
		property int iconSize: 30
		property string name : 'file'
		property string icon : 'file_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg').color
	}
	property QtObject folder: QtObject {
		property int iconSize: 30
		property string name : 'folder'
		property string icon : 'folder_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg').color
	}
}
