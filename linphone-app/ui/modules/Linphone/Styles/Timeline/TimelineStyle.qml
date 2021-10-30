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
			property color a: ColorsList.add(sectionName+'_contact_bg_a', 'g10').color
			property color b: ColorsList.add(sectionName+'_contact_bg_b', 'a').color
			property color selected: ColorsList.add(sectionName+'_contact_bg_c', 'i').color
		}
		
		property QtObject sipAddress: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_contact_sipAddress_n', 'n').color
				property color selected: ColorsList.add(sectionName+'_contact_sipAddress_c', 'q').color
			}
		}
		
		property QtObject username: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_contact_username_n', 'j').color
				property color selected: ColorsList.add(sectionName+'_contact_username_c', 'q').color
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
	}
}
