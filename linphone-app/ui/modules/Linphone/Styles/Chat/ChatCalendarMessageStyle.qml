pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatCalendarMessage'
	property int topMargin:  0
	property int widthMargin:  5
	property int minWidth: 300
		
		property int actionButtonsSize: 36
		property int avatarSize: 30
		property int deleteButtonSize: 22
		property int height: 50
		property int leftMargin: 40
		property int bottomMargin: 10
		property int presenceLevelSize: 12
		property int rightMargin: 25
		property int spacing: 15
		property int lineHeight: 20
		
		property QtObject backgroundColor: QtObject {
			property color normal: ColorsList.add(sectionName+'_conference_bg_n', 'conference_bg').color
			property color hovered: ColorsList.add(sectionName+'_conference_bg_h', 'g10').color
		}
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_border', 'f').color
			property int width: 1
		}
		
		property QtObject indicator: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_indicator', 'i').color
			property int width: 5
		}
		
		property QtObject schedule: QtObject {
			property int spacing: 0
			property int pointSize: Units.dp * 9
			property string icon : 'schedule_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_schedule', 'j').color
		}
		property QtObject subject: QtObject {
			property int spacing: 5
			property int pointSize: Units.dp * 11
			property color color: ColorsList.add(sectionName+'_subject', 'j').color
		}
		property QtObject description: QtObject {
			property int spacing: 5
			property int pointSize: Units.dp * 9
			property color color: ColorsList.add(sectionName+'_description', 'j').color
		}
		property QtObject participants: QtObject {
			property int spacing: 5
			property int pointSize: Units.dp * 9
			property string icon : 'calendar_participants_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_participants', 'j').color
		}
		
		property QtObject gotoButton: QtObject{
			property int iconSize: 20
			property string name : 'goto'
			property string icon : 'transfer_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg').color
		}
		property QtObject infoButton: QtObject{
			property int iconSize: 35
			property string name : 'info'
			property string icon : 'menu_info_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 'me_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 'me_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 'me_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 'me_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 'me_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 'me_p_b_fg').color
		}
		
		property QtObject organizer: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_organizer', 'j').color
			property int pointSize: Units.dp * 9
			property int width: 220
		}
	
	
	
	/*
	property color color: ColorsList.add(sectionName, 'q').color
	property QtObject header: QtObject{
		property color color: ColorsList.add(sectionName+'_header', 'h').color
		property int pointSizeOffset: -3
		property QtObject forwardIcon: QtObject{
			property string icon : 'menu_forward_custom'
			property int iconSize: 22
		}
	}
		
	property int padding: 8
	*/
	
}
