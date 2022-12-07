pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Timeline'
	property color color: ColorsList.add(sectionName+'_bg', 'q').color
	
	property QtObject ephemeralTimer: QtObject{
		property string icon: 'timer_custom'
		property int iconSize : 30
		property color timerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer', icon, 'ad').color
		property color selectedTimerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer_c', icon, 'q').color
	}
	
	property QtObject contact: QtObject {
		property int height: 60
		
		property QtObject backgroundColor: QtObject {
			property color a: ColorsList.add(sectionName+'_contact_bg_a', 'timeline_bg_1').color
			property color b: ColorsList.add(sectionName+'_contact_bg_b', 'timeline_bg_2').color
			property color selected: ColorsList.add(sectionName+'_contact_bg_c', 'i').color
		}
		
		property QtObject subtitle: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_contact_subtitle_n', 'n').color
				property color selected: ColorsList.add(sectionName+'_contact_subtitle_c', 'q').color
			}
		}
		
		property QtObject title: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_contact_title_n', 'j').color
				property color selected: ColorsList.add(sectionName+'_contact_title_c', 'q').color
			}
		}
	}
	
	property QtObject legend: QtObject {
		property QtObject backgroundColor: QtObject {
			property color normal: ColorsList.add(sectionName+'_legend_bg_n', 'f').color
			property color hovered: ColorsList.add(sectionName+'_legend_bg_h', 'c').color
		}
		property color color: ColorsList.add(sectionName+'_legend', 'd').color
		property int pointSize: Units.dp * 10
		property int height: 30
		property int iconSize: 28
		property int leftMargin: 17
		property int rightMargin: 17
		property int lastRightMargin: 5
		property int spacing: 1
	}
	property QtObject filterField: QtObject {
		property color borderColor: ColorsList.add(sectionName+'_filter_border', 'border').color
	}
		
	property QtObject searchField: QtObject {
		property color color: ColorsList.add(sectionName+'_searchField', 'c').color
		property color borderColor: ColorsList.add(sectionName+'_searchField_border', 'border').color
		property int pointSize: Units.dp * 9
	}
	
	property QtObject selectedDeleteAction: QtObject {
		property int iconSize: 40
		property string name : 'delete_on_selected'
		property string icon : 'delete_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_inv_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_inv_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_inv_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_inv_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_inv_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_inv_fg').color
	}
	
	property QtObject deleteAction: QtObject {
		property int iconSize: 40
		property string name : 'delete'
		property string icon : 'delete_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
	}
}
