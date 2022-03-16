pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'DroppableTextArea'
	property color backgroundColor: ColorsList.add(sectionName+'_Chat_bg', 'e').color
	property color outsideBackgroundColor: ColorsList.add(sectionName+'_Chat_outsideBackground', 'aa').color
	
	property QtObject ephemeralTimer: QtObject{
		property string icon: 'timer_custom'
		property int iconSize : 30
		property color timerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer', icon, 'ad').color
	}
	
	property QtObject fileChooserButton: QtObject {
		property int margins: 6
		property int iconSize: 40
		property string icon : 'attachment_custom'
		property string name : 'attachment'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'me_d_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'me_d_b_fg').color
		
	}
	property QtObject chatMicro: QtObject {
		property int margins: 6
		property int iconSize: 40
		property string name : 'micro'
		property string icon : 'chat_micro_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'me_p_b_bg').color
		property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'me_d_b_bg').color
		
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		property color foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'me_p_b_fg').color
		property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'me_d_b_fg').color
		
	}
	property QtObject send: QtObject {
		property int margins: 5
		property int iconSize: 30
		property string name : 'send'
		property string icon : 'send_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		
	}
	
	property QtObject hoverContent: QtObject {
		property color backgroundColor: ColorsList.add(sectionName+'_Chat_hoverContent_bg', 'q').color
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_Chat_hoverContent_text', 'i').color
			property int pointSize: Units.dp * 11
		}
	}
	
	property QtObject text: QtObject {
		property color color: ColorsList.add(sectionName+'_Chat_text', 'd').color
		property int pointSize: Units.dp * 10
	}
}
