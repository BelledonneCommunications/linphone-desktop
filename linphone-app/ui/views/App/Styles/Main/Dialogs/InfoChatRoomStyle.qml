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
		property var colorModel : ColorsList.add(sectionName+'_results', 'g')
		property QtObject title : QtObject{
			property int topMargin: 10
			property int leftMargin: 20
			property var colorModel: ColorsList.add(sectionName+'_results_title', 'j')
			property int pointSize : Units.dp * 11
			property int weight : Font.DemiBold
		}
		property QtObject header: QtObject{
			property int rightMargin: 55
			property var colorModel: ColorsList.add(sectionName+'_results_header', 'j')
			property int weight : Font.Light
			property int pointSize : Units.dp * 10
			
		}
	}	
	
	property QtObject leaveButton : 
	QtObject {
		property QtObject backgroundColor: QtObject {
			property var disabled: ColorsList.add(sectionName+'_leave_bg_d', 'o')
			property var hovered: ColorsList.add(sectionName+'_leave_bg_h', 'j')
			property var normal: ColorsList.add(sectionName+'_leave_bg_n', 'k')
			property var pressed: ColorsList.add(sectionName+'_leave_bg_p', 'i')
		}
		
		property QtObject textColor: QtObject {
			property var disabled: ColorsList.add(sectionName+'_leave_text_d', 'q')
			property var hovered: ColorsList.add(sectionName+'_leave_text_h', 'q')
			property var normal: ColorsList.add(sectionName+'_leave_text_n', 'i')
			property var pressed: ColorsList.add(sectionName+'_leave_text_p', 'q')
		}
		property QtObject borderColor : QtObject{
			property var disabled: ColorsList.add(sectionName+'_leave_border_d', 'q')
			property var hovered: ColorsList.add(sectionName+'_leave_border_h', 'q')
			property var normal: ColorsList.add(sectionName+'_leave_border_n', 'i')
			property var pressed: ColorsList.add(sectionName+'_leave_border_p', 'q')
		}
	}
	property QtObject addParticipant: QtObject {
		property int iconSize: 30
		property string name : 'addParticipant'
		property string icon : 'add_participant_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
	}
	property QtObject removeParticipant: QtObject {
		property int iconSize: 30
		property string name : 'removeParticipant'
		property string icon : 'remove_participant_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
	}
}