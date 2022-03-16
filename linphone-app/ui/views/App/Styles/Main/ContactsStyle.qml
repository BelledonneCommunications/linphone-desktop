pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Contacts'
	property color backgroundColor: ColorsList.add(sectionName+'_bg', 'k').color
	property int spacing: 20
	
	property QtObject filter: QtObject {
		property string icon: 'filter_custom'
		property color color: ColorsList.add(sectionName+'_filter_icon', 'c').color
	}
	property QtObject bar: QtObject {
		property color backgroundColor: ColorsList.add(sectionName+'_bar_bg', 'e').color
		property int height: 60
		property int leftMargin: 18
		property int rightMargin: 18
	}
	
	property QtObject contact: QtObject {
		property int actionButtonsSize: 36
		property int avatarSize: 30
		property int deleteButtonSize: 22
		property int height: 50
		property int leftMargin: 40
		property int presenceLevelSize: 12
		property int rightMargin: 25
		property int spacing: 15
		
		property QtObject backgroundColor: QtObject {
			property color normal: ColorsList.add(sectionName+'_contact_bg_n', 'k').color
			property color hovered: ColorsList.add(sectionName+'_contact_bg_h', 'g10').color
		}
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_contact_border', 'f').color
			property int width: 1
		}
		
		property QtObject indicator: QtObject {
			property color color: ColorsList.add(sectionName+'_contact_indicator', 'i').color
			property int width: 5
		}
		
		property QtObject presence: QtObject {
			property int pointSize: Units.dp * 10
			property color color: ColorsList.add(sectionName+'_contact_presence', 'n').color
		}
		
		property QtObject username: QtObject {
			property color color: ColorsList.add(sectionName+'_contact_username', 'j').color
			property int pointSize: Units.dp * 10
			property int width: 220
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
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg').color
	}
	property QtObject history: QtObject {
		property int iconSize: 36
		property string icon : 'history_custom'
		property string name : 'history'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg').color
	}
	property QtObject deleteAction: QtObject {
		property int iconSize: 36
		property string name : 'delete'
		property string icon : 'contact_delete_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
}
