pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'SettingsWindow'
	property color color: ColorsList.add(sectionName+'_bg', 'k').color
	property int height: 640
	property int width: 1024
	
	property QtObject forms: QtObject {
		property int spacing: 10
	}
	
	property QtObject validButton: QtObject {
		property int bottomMargin: 30
		property int rightMargin: 30
		property int topMargin: 30
	}
	
	property QtObject sipAccounts: QtObject {
		property int buttonsSpacing: 8
		property int iconSize: 22
		property int legendLineWidth: 280
	}
	property QtObject video: QtObject {
		property QtObject warningMessage: QtObject {
			property int iconSize: 20
		}
	}
	property QtObject buttons: QtObject {
		property QtObject editProxy: QtObject {
			property int iconSize: 36
			property string name : 'editProxy'
			property string icon : 'edit_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		}
		property QtObject deleteProxy: QtObject {
			property int iconSize: 36
			property string name : 'deleteProxy'
			property string icon : 'delete_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		}
	}
}
