pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'Calls'
	property QtObject entry: QtObject {
		property int iconActionSize: 35
		property int iconMenuSize: 35
		property int height: 30
		property int width: 200
		
		property QtObject color: QtObject {
			property color normal: ColorsList.add('Calls_entry_n', 'e').color
			property color selected: ColorsList.add('Calls_entry_c', 'j').color
		}
		property QtObject burgerMenu: QtObject {
			property string name : 'burgerMenu'
			property string icon : 'burger_menu_custom'
			property int iconSize: 35
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		}
		property QtObject selectedBurgerMenu: QtObject {
			property string name : 'selectedBurgerMenu'
			property string icon : 'burger_menu_custom'
			property int iconSize: 35
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_inv_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_inv_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg').color
		}
		property QtObject hangup: QtObject {
			property int iconSize: 35
			property string icon : 'hangup_custom'
			property string name : 'hangup'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'r_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'r_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'r_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'r_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'r_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'r_p_b_fg').color
		}
		property QtObject endCallAnimation: QtObject {
			property color blinkColor: ColorsList.add('Calls_entry_end_blink', 'i').color
			property int duration: 300
			property int loops: 3
		}
		
		property QtObject sipAddressColor: QtObject {
			property color normal: ColorsList.add('Calls_entry_sipAddress_n', 'n').color
			property color selected: ColorsList.add('Calls_entry_sipAddress_selected', 'q').color
		}
		
		property QtObject usernameColor: QtObject {
			property color normal: ColorsList.add('Calls_entry_username_n', 'j').color
			property color selected: ColorsList.add('Calls_entry_username_selected', 'q').color
		}
		
	}
}
