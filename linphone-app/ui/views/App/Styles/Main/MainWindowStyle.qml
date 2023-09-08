pragma Singleton
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'MainWindow'
	property int menuBurgerSize: 40
	property int newConferenceSize: 40
	property int minimumHeight: 610
	property int minimumWidth: 950
	property int width: 950
	property int panelButtonSize : 20
	property int homeButtonSize: 40
	
	property QtObject accountStatus: QtObject {
		property int width: 200
	}
	
	property QtObject autoAnswerStatus: QtObject {
		property int iconSize: 16
		property int width: 28
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 8
			property var colorModel: ColorsList.add(sectionName+'_auto_answer_text', 'i')
		}
	}
	
	property QtObject menu: QtObject {
		property int height: 50
		property int width: 250
		property int leftMargin: 15
		property int rightMargin: 15
		property int spacing: 10
		property int buttonSize: 38
		
		property QtObject direction: QtObject {
			property string icon: 'panel_arrow_custom'
			property int iconSize: 30
		}
		property QtObject contacts: QtObject {
			property string icon: 'contact_custom'
			property int iconSize: 50
			property var colorModel: ColorsList.add(sectionName+'_me_contacts', 'me_n_b_inv_fg')
			property var selectedColor: ColorsList.add(sectionName+'_me_contacts_c', 'me_p_b_inv_fg')
		}
		property QtObject conferences: QtObject {
			property string icon: 'meetings_custom'
			property int iconSize: 50
			property var colorModel: ColorsList.add(sectionName+'_me_conferences', 'me_n_b_inv_fg')
			property var selectedColor: ColorsList.add(sectionName+'_me_conferences_c', 'me_p_b_inv_fg')
		}
		property QtObject recordings: QtObject {
			property string icon: 'recordings_custom'
			property int iconSize: 50
			property color color: ColorsList.add(sectionName+'_me_recordings', 'me_n_b_inv_fg').color
			property color selectedColor: ColorsList.add(sectionName+'_me_recordings_c', 'me_p_b_inv_fg').color
		}
		/*
		property string conferencesIcon: 'conference'
		property var conferencesColor: ColorsList.add(sectionName+'_me_confs', 'me_n_b_inv_fg')
		property var conferencesSelectedColor: ColorsList.add(sectionName+'_me_confs_selected', 'me_p_b_inv_fg')*/
		
	}
	
	property QtObject searchBox: QtObject {
		property int maxHeight: 300 // See Hick's law for good choice.
	}
	
	property QtObject toolBar: QtObject {
		property int height: 70
		property int leftMargin: 18
		property int rightMargin: 18
		property int spacing: 10
		
		property var background: Rectangle {
			property var colorModel: ColorsList.add(sectionName+'_toolbar_bg', 'f')
			color: colorModel.color
		}
	}
	
	property QtObject buttons: QtObject {
		property QtObject home: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'home'
			property string icon : 'home_custom'
			property var backgroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var foregroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
		}
		property QtObject telKeyad: QtObject {
			property int iconSize: 40
			property string name : 'telKeypad'
			property string icon : 'dialpad_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'l_u_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'l_u_b_fg')
		}
		property QtObject newChatGroup: QtObject {
			property int iconSize: 40
			property string name : 'newChatGroup'
			property string icon : 'new_chat_group_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'ma_d_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
			property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'ma_d_b_fg')
		}
		property QtObject newConference: QtObject {
			property int iconSize: 40
			property string name : 'newConference'
			property string icon : 'conference_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 'ma_d_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
			property var foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 'ma_d_b_fg')
		}
		property QtObject burgerMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'burgerMenu'
			property string icon : 'burger_menu_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'l_u_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'l_u_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
		}
		property QtObject settingsMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'settingsMenu'
			property string icon : 'options_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'l_u_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'l_u_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
		}
		property QtObject callHistoryMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'callHistory'
			property string icon : 'call_history_custom'
			property var backgroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var foregroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
		}
		property QtObject chatMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'chat'
			property string icon : 'chat_custom'
			property var backgroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var foregroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
		}
		
		property QtObject contactsMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'contacts'
			property string icon : 'contact_custom'
			property var backgroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var foregroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
		}
		
		property QtObject meetingsMenu: QtObject {
			property int iconSize: menu.buttonSize
			property string name : 'meetings'
			property string icon : 'meetings_custom'
			property var backgroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg')
			property var backgroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg')
			property var backgroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'ma_h_b_bg')
			property var backgroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg')
			property var foregroundNormalColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg')
			property var foregroundHoveredColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg')
			property var foregroundUpdatingColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'ma_h_b_fg')
			property var foregroundPressedColor: ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg')
		}
		
	}
}
