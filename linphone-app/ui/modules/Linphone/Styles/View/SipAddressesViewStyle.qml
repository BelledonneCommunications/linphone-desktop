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
			property color hovered: ColorsList.add(sectionName+'_entry_h', 'o').color
			property color normal: ColorsList.add(sectionName+'_entry_n', 'q').color
		}
		
		property QtObject indicator: QtObject {
			property color color: ColorsList.add(sectionName+'_entry_indicator', 'i').color
			property int width: 5
		}
		
		property QtObject separator: QtObject {
			property color color: ColorsList.add(sectionName+'_entry_separator', 'c').color
			property int height: 1
		}
	}
	
	property QtObject header: QtObject {
		property int iconSize: 40
		property int leftMargin: 20
		property int rightMargin: 10
		
		property QtObject button: QtObject {
			property int height: 40
			property color color: ColorsList.add(sectionName+'_header_button', 'q').color
		}
		
		property QtObject color: QtObject {
			property color normal: ColorsList.add(sectionName+'_header_n', 'j').color
			property color pressed: ColorsList.add(sectionName+'_header_p', 'i').color
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 9
			
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_header_text_n', 'q').color
				property color pressed: ColorsList.add(sectionName+'_header_text_p', 'q').color
			}
		}
	}
	property QtObject videoCall: QtObject {
		property int iconSize: 36
		property string name : 'videoCall'
		property string icon : 'video_call_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject call: QtObject {
		property int iconSize: 36
		property string name : 'call'
		property string icon : 'call_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject chat: QtObject {
		property int iconSize: 36
		property string name : 'chat'
		property string icon : 'chat_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject history: QtObject {
		property int iconSize: 36
		property string icon : 'history_custom'
		property string name : 'history'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	
}
