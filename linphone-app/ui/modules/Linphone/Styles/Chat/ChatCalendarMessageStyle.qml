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
	
	//property var : ColorsList.add(sectionName+'_conference_bg_n', 'conference_entry_bg')
	
	property QtObject backgroundColor: QtObject {
		property var normal: ColorsList.add(sectionName+'_conference_bg_n', 'conference_entry_bg')
		property var hovered: ColorsList.add(sectionName+'_conference_bg_h', 'g10')
	}
	
	property QtObject border: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_conference_border', 'f')
		property int width: 1
	}
	
	property QtObject indicator: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_conference_indicator', 'i')
		property int width: 5
	}
	property QtObject calendar: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 9
		property string icon : 'calendar_custom'
		property int iconSize: 30
		property var colorModel: ColorsList.add(sectionName+'_schedule', 'j')
	}
	property QtObject schedule: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 9
		property string icon : 'schedule_custom'
		property int iconSize: 30
		property var colorModel: ColorsList.add(sectionName+'_schedule', 'j')
	}
	property QtObject type: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 10
		property var updatedColor: ColorsList.add(sectionName+'_updated_subject', 'updated_ics_fg')
		property var cancelledColor: ColorsList.add(sectionName+'_cancelled_subject', 'cancelled_ics_fg')
		property var colorModel: ColorsList.add(sectionName+'_subject', 'ics_fg')
	}
	property QtObject subject: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 11
		property var colorModel: ColorsList.add(sectionName+'_subject', 'j')
	}
	property QtObject description: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 9
		property var colorModel: ColorsList.add(sectionName+'_description', 'j')
	}
	property QtObject participants: QtObject {
		property int spacing: 5
		property int pointSize: Units.dp * 9
		property string icon : 'calendar_participants_custom'
		property int iconSize: 25
		property var colorModel: ColorsList.add(sectionName+'_participants', 'j')
	}
	
	property QtObject gotoButton: QtObject{
		property int iconSize: 20
		property string name : 'goto'
		property string icon : 'transfer_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg')
		property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_c', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg')
		property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_c', icon, 's_p_b_fg')
	}
	property QtObject infoButton: QtObject{
		property int iconSize: 25
		property string name : 'info'
		property string icon : 'menu_info_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 'me_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 'me_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 'me_p_b_bg')
		property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_c', icon, 'me_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 'me_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 'me_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 'me_p_b_fg')
		property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_c', icon, 'me_p_b_fg')
	}
	
	property QtObject organizer: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_conference_organizer', 'j')
		property int pointSize: Units.dp * 9
		property int width: 220
	}
	property QtObject copyLinkButton: QtObject{
		property int iconSize: 40
		property string name : 'copy'
		property string icon : 'menu_copy_text_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg')
	}
	property QtObject shareButton: QtObject{
		property int iconSize: 40
		property string name : 'share'
		property string icon : 'settings_network_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 'me_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 'me_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 'me_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 'me_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 'me_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 'me_p_b_fg')
	}
	
	
	property QtObject editButton: QtObject{
		property int iconSize: 40
		property string name : 'edit'
		property string icon : 'ics_edit_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg')
	}
	property QtObject deleteButton: QtObject{
		property int iconSize: 40
		property string name : 'delete'
		property string icon : 'delete_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg')
	}
	
}
