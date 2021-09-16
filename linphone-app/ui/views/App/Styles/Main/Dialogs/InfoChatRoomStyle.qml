pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property string sectionName: 'InfoChatRoom'
	property int height: 500
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 25
		property int rightMargin: 25
		property int spacing: 7
	}
	
	property QtObject searchBar : QtObject{
		property int topMargin : 10
	}
	
	property QtObject results : QtObject{
		property int topMargin : 10
		property color color : ColorsList.add(sectionName+'_results', 'g').color
		property QtObject title : QtObject{
			property int topMargin: 10
			property int leftMargin: 20
			property color color: ColorsList.add(sectionName+'_results_title', 'j').color
			property int pointSize : Units.dp * 11
			property int weight : Font.DemiBold
		}
		property QtObject header: QtObject{
			property int rightMargin: 55
			property color color: Colors.t.color
			property int weight : Font.Light
			property int pointSize : Units.dp * 10
			
		}
	}	
	
	property QtObject leaveButton : 
	QtObject {
		property QtObject backgroundColor: QtObject {
			property color disabled: ColorsList.add(sectionName+'_leave_bg_d', 'o').color
			property color hovered: ColorsList.add(sectionName+'_leave_bg_h', 'j').color
			property color normal: ColorsList.add(sectionName+'_leave_bg_n', 'k').color
			property color pressed: ColorsList.add(sectionName+'_leave_bg_p', 'i').color
		}
		
		property QtObject textColor: QtObject {
			property color disabled: ColorsList.add(sectionName+'_leave_text_d', 'q').color
			property color hovered: ColorsList.add(sectionName+'_leave_text_h', 'q').color
			property color normal: ColorsList.add(sectionName+'_leave_text_n', 'i').color
			property color pressed: ColorsList.add(sectionName+'_leave_text_p', 'q').color
		}
		property QtObject borderColor : QtObject{
			property color disabled: ColorsList.add(sectionName+'_leave_border_d', 'q').color
			property color hovered: ColorsList.add(sectionName+'_leave_border_h', 'q').color
			property color normal: ColorsList.add(sectionName+'_leave_border_n', 'i').color
			property color pressed: ColorsList.add(sectionName+'_leave_border_p', 'q').color
		}
	}
	property QtObject addParticipant: QtObject {
		property int iconSize: 30
		property string name : 'addParticipant'
		property string icon : 'add_participant_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg').color
	}
	property QtObject removeParticipant: QtObject {
		property int iconSize: 30
		property string name : 'removeParticipant'
		property string icon : 'remove_participant_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg').color
	}
}