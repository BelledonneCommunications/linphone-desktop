pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property string sectionName: 'NewConference'
	
	property var askEncryptionColor: ColorsList.add(sectionName+'_ask_encryption', 'g')
	property var subjectTitleColor: ColorsList.add(sectionName+'_subject_title', 'g')
	property var recentContactTitleColor: ColorsList.add(sectionName+'_recent_contact_title', 'g')
	property var recentContactUsernameColor: ColorsList.add(sectionName+'_recent_contact_username', 'g')
	property var addressesBorderColor: ColorsList.add(sectionName+'_addresses_border', 'border_light')
	property var addressesAdminColor: ColorsList.add(sectionName+'_addresses_admin', 'g')
	property var requiredColor: ColorsList.add(sectionName+'_required_text', 'g')
	
	property QtObject busy: QtObject{
		property var colorModel: ColorsList.add(sectionName+'_busy', 'i')
		property real pointSize: Units.dp * 10
	}
	
	property QtObject titles: QtObject{
		property var textColor: ColorsList.add(sectionName+'_schedule_titles', 'g')
		property int weight: Font.DemiBold
		property real pointSize: Units.dp * 10
	}
	property QtObject fields: QtObject{
		property var textColor: ColorsList.add(sectionName+'_schedule_fields', 'g')
		property int weight: Font.Medium
		property real pointSize: Units.dp * 9
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