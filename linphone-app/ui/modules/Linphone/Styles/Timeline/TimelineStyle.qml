pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Timeline'
	property var colorModel: ColorsList.add(sectionName+'_bg', 'q')
	property QtObject status: QtObject{
		property int iconSize : 30
	}
	
	property QtObject disabledNotifications: QtObject{
		property string icon: 'notifications_off_custom'
		property var colorModel: ColorsList.addImageColor(sectionName+'_disabledNotifications', icon, 'ad')
		property var selectedColorModel: ColorsList.addImageColor(sectionName+'_disabledNotifications_c', icon, 'q')
	}
	
	property QtObject ephemeralTimer: QtObject{
		property string icon: 'timer_custom'
		property int iconSize : 30
		property var timerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer', icon, 'ad')
		property var selectedTimerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer_c', icon, 'q')
	}
	
	property QtObject contact: QtObject {
		property int height: 60
		
		property QtObject backgroundColor: QtObject {
			property var a: ColorsList.add(sectionName+'_contact_bg_a', 'timeline_bg_1')
			property var b: ColorsList.add(sectionName+'_contact_bg_b', 'timeline_bg_2')
			property var selected: ColorsList.add(sectionName+'_contact_bg_c', 'i')
		}
		
		property QtObject subtitle: QtObject {
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_contact_subtitle_n', 'n')
				property var selected: ColorsList.add(sectionName+'_contact_subtitle_c', 'q')
			}
		}
		
		property QtObject title: QtObject {
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_contact_title_n', 'j')
				property var selected: ColorsList.add(sectionName+'_contact_title_c', 'q')
			}
		}
	}
	
	property QtObject legend: QtObject {
		property QtObject backgroundColor: QtObject {
			property var normal: ColorsList.add(sectionName+'_legend_bg_n', 'f')
			property var hovered: ColorsList.add(sectionName+'_legend_bg_h', 'c')
		}
		property var colorModel: ColorsList.add(sectionName+'_legend', 'd')
		property int pointSize: Units.dp * 10
		property int height: 30
		property int iconSize: 28
		property int leftMargin: 17
		property int rightMargin: 17
		property int lastRightMargin: 5
		property int spacing: 1
	}
	property QtObject filterField: QtObject {
		property var borderColor: ColorsList.add(sectionName+'_filter_border', 'border')
	}
		
	property QtObject searchField: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_searchField', 'c')
		property var borderColor: ColorsList.add(sectionName+'_searchField_border', 'border')
		property int pointSize: Units.dp * 9
	}
	
	property QtObject selectedDeleteAction: QtObject {
		property int iconSize: 40
		property string name : 'delete_on_selected'
		property string icon : 'delete_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_inv_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_inv_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg')
	}
	
	property QtObject deleteAction: QtObject {
		property int iconSize: 40
		property string name : 'delete'
		property string icon : 'delete_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
	}
}
