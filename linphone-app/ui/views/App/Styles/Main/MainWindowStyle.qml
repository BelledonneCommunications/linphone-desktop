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
			property color color: ColorsList.add(sectionName+'_auto_answer_text', 'i').color
		}
	}
	
	property QtObject menu: QtObject {
		property int height: 50
		property int width: 250
		
		property QtObject direction: QtObject {
			property string icon: 'panel_arrow_custom'
			property int iconSize: 30
		}
		property QtObject contacts: QtObject {
			property string icon: 'contact_custom'
			property int iconSize: 50
			property color color: ColorsList.add(sectionName+'_me_contacts', 'me_n_b_inv_fg').color
			property color selectedColor: ColorsList.add(sectionName+'_me_contacts_c', 'me_p_b_inv_fg').color
		}		
		/*
		property string conferencesIcon: 'conference'
		property color conferencesColor: ColorsList.add(sectionName+'_me_confs', 'me_n_b_inv_fg').color
		property color conferencesSelectedColor: ColorsList.add(sectionName+'_me_confs_selected', 'me_p_b_inv_fg').color*/
		
	}
	
	property QtObject searchBox: QtObject {
		property int maxHeight: 300 // See Hick's law for good choice.
	}
	
	property QtObject toolBar: QtObject {
		property int height: 70
		property int leftMargin: 18
		property int rightMargin: 18
		property int spacing: 16
		
		property var background: Rectangle {
			color: ColorsList.add(sectionName+'_toolbar_bg', 'f').color
		}
	}
	property QtObject buttons: QtObject {
		property QtObject home: QtObject {
			property int iconSize: 40
			property string name : 'home'
			property string icon : 'home_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg').color
		}
		property QtObject newChatGroup: QtObject {
			property int iconSize: 40
			property string name : 'newChatGroup'
			property string icon : 'new_chat_group_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg').color
		}
		property QtObject newConference: QtObject {
			property int iconSize: 40
			property string name : 'newConference'
			property string icon : 'new_conference_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg').color
		}
		property QtObject burgerMenu: QtObject {
			property int iconSize: 40
			property string name : 'burgerMenu'
			property string icon : 'burger_menu_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
		}
	}
}
