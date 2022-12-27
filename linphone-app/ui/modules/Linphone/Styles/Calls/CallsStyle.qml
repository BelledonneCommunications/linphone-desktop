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
			property var normal: ColorsList.add('Calls_entry_n', 'e')
			property var selected: ColorsList.add('Calls_entry_c', 'j')
		}
		property QtObject burgerMenu: QtObject {
			property string name : 'burgerMenu'
			property string icon : 'menu_vdots_custom'
			property int iconSize: 35
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		}
		property QtObject selectedBurgerMenu: QtObject {
			property string name : 'selectedBurgerMenu'
			property string icon : 'menu_vdots_custom'
			property int iconSize: 35
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_inv_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_inv_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg')
		}
		
		property QtObject hangup: QtObject {
			property int iconSize: 35
			property string icon : 'hangup_custom'
			property string name : 'hangup'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'r_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'r_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'r_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'r_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'r_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'r_p_b_fg')
		}
		property QtObject endCallAnimation: QtObject {
			property var blinkColor: ColorsList.add('Calls_entry_end_blink', 'i')
			property int duration: 300
			property int loops: 3
		}
		
		property QtObject subtitleColor: QtObject {
			property var normal: ColorsList.add('Calls_entry_subtitle_n', 'n')
			property var selected: ColorsList.add('Calls_entry_subtitle_selected', 'q')
		}
		
		property QtObject titleColor: QtObject {
			property var normal: ColorsList.add('Calls_entry_title_n', 'j')
			property var selected: ColorsList.add('Calls_entry_title_selected', 'q')
		}
		
	}
}
