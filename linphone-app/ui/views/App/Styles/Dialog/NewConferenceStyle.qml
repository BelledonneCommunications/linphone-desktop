pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property string sectionName: 'NewConference'
	
	property color askEncryptionColor: ColorsList.add(sectionName+'_ask_encryption', 'g').color
	property color subjectTitleColor: ColorsList.add(sectionName+'_subject_title', 'g').color
	property color recentContactTitleColor: ColorsList.add(sectionName+'_recent_contact_title', 'g').color
	property color recentContactUsernameColor: ColorsList.add(sectionName+'_recent_contact_username', 'g').color
	property color addressesBorderColor: ColorsList.add(sectionName+'_addresses_border', 'border_light').color
	property color addressesAdminColor: ColorsList.add(sectionName+'_addresses_admin', 'g').color
	property color requiredColor: ColorsList.add(sectionName+'_required_text', 'g').color
	
	property QtObject titles: QtObject{
		property color textColor: ColorsList.add(sectionName+'_schedule_titles', 'g').color
		property int weight: Font.DemiBold
		property real pointSize: Units.dp * 10
	}
	property QtObject fields: QtObject{
		property color textColor: ColorsList.add(sectionName+'_schedule_fields', 'g').color
		property int weight: Font.Medium
		property real pointSize: Units.dp * 9
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