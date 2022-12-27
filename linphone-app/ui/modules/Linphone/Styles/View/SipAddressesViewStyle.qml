pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'SipAddressesView'
	property QtObject entry: QtObject {
		property int height: 50
		property int iconSize: 36
		property int rightMargin: 10
		
		property QtObject color: QtObject {
			property var hovered: ColorsList.add(sectionName+'_entry_h', 'o')
			property var normal: ColorsList.add(sectionName+'_entry_n', 'q')
		}
		
		property QtObject indicator: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_entry_indicator', 'i')
			property int width: 5
		}
		
		property QtObject separator: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_entry_separator', 'c')
			property int height: 1
		}
	}
	
	property QtObject header: QtObject {
		property int iconSize: 40
		property int leftMargin: 20
		property int rightMargin: 10
		
		property QtObject button: QtObject {
			property int height: 40
			property var colorModel: ColorsList.add(sectionName+'_header_button', 'q')
		}
		
		property QtObject color: QtObject {
			property var normal: ColorsList.add(sectionName+'_header_n', 'j')
			property var pressed: ColorsList.add(sectionName+'_header_p', 'i')
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 9
			
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_header_text_n', 'q')
				property var pressed: ColorsList.add(sectionName+'_header_text_p', 'q')
			}
		}
	}
	property QtObject videoCall: QtObject {
		property int iconSize: 36
		property string name : 'videoCall'
		property string icon : 'video_call_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject call: QtObject {
		property int iconSize: 36
		property string name : 'call'
		property string icon : 'call_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject chat: QtObject {
		property int iconSize: 36
		property string name : 'chat'
		property string icon : 'chat_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject history: QtObject {
		property int iconSize: 36
		property string icon : 'history_custom'
		property string name : 'history'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	
}
