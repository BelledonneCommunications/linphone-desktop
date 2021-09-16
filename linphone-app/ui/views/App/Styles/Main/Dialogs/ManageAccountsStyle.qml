pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ManageAccounts'
	property int height: 383
	property int heightWithoutPresence: 314
	property int width: 450
	
	property QtObject accountSelector: QtObject {
		property int height: 176
	}
	property QtObject options: QtObject {
			property int iconSize: 30
			property string icon : 'options_custom'
			property string name : 'options'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		}
}
