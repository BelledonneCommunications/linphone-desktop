pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ConferenceManager'
	property int height: 420
	property int width: 740
	
	property QtObject columns: QtObject {
		property QtObject selector: QtObject {
			property int spacing: 10
		}
		
		property QtObject separator: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_separator', 'c')
			property int leftMargin: 25
			property int rightMargin: 25
			property int width: 1
		}
	}
	property QtObject transfer: QtObject {
		property int iconSize: 36
		property string icon : 'transfer_custom'
		property string name : 'transfer'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject cancel: QtObject {
		property int iconSize: 36
		property string icon : 'cancel_custom'
		property string name : 'cancel'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject searchField: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_searchField', 'c')
	}
}
