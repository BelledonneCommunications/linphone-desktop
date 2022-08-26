pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Conferences'
	property color backgroundColor: ColorsList.add(sectionName+'_bg', 'k').color
	property int spacing: 20
	
	property QtObject filter: QtObject {
		property string icon: 'filter_custom'
		property color color: ColorsList.add(sectionName+'_filter_icon', 'c').color
		
		property QtObject buttons: QtObject{
			property int buttonsSpacing: 8
			
			property QtObject button: QtObject {
				property QtObject color: QtObject {
					property color hovered: ColorsList.add(sectionName+'_button_h', 'n').color
					property color normal: ColorsList.add(sectionName+'_button_n', 'x').color
					property color pressed: ColorsList.add(sectionName+'_button_p', 'g').color
					property color selected: ColorsList.add(sectionName+'_button_c', 'i').color
				}
			}
		}

	}
	property QtObject bar: QtObject {
		property color backgroundColor: ColorsList.add(sectionName+'_bar_bg', 'e').color
		property int height: 60
		property int leftMargin: 18
		property int rightMargin: 18
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property color color: ColorsList.add(sectionName+'_bar_text', 'j').color
		}
	}
	
	property QtObject conference: QtObject {
		property string name: 'conference'
		property int actionButtonsSize: 36
		property int avatarSize: 30
		property int deleteButtonSize: 22
		property int height: 50
		property int leftMargin: 40
		property int bottomMargin: 10
		property int presenceLevelSize: 12
		property int rightMargin: 25
		property int spacing: 15
		
		property QtObject backgroundColor: QtObject {
			property color ended: ColorsList.add(sectionName+'_conference_ended_bg', 'conference_entry_bg').color
			property color scheduled: ColorsList.add(sectionName+'_conference_scheduled_bg', 'e').color
			property color hovered: ColorsList.add(sectionName+'_conference_bg_h', 'g10').color
		}
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_border', 'f').color
			property int width: 1
		}
		property QtObject selectedBorder: QtObject{
			property color color: ColorsList.add(sectionName+'_conference_selected_border', 'm').color	
			property int width: 2
		}
		
		property QtObject indicator: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_indicator', 'i').color
			property int width: 5
		}
		
		property QtObject schedule: QtObject {
			property int pointSize: Units.dp * 10
			property string icon : 'schedule_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_schedule', 'j').color
		}
		property QtObject participants: QtObject {
			property int pointSize: Units.dp * 10
			property string icon : 'contact_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_participants', 'j').color
		}
		
		property QtObject organizer: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_organizer', 'j').color
			property int pointSize: Units.dp * 10
			property int width: 220
		}
	}
	property QtObject sectionHeading: QtObject {
		property string name: 'sectionHeading'
		property int padding: 5
		property int bottomMargin: 20
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_sectionHeading_border', 'g10').color
			property int width: 1
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property color color: ColorsList.add(sectionName+'_sectionHeading_text', 'ab').color
		}
	}
	/*
	property QtObject schedule: QtObject {
		property int iconSize: 36
		property string icon : 'schedule_custom'
		property string name : 'schedule'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}*/
	
//----------------------------------------------------------------------------------

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
