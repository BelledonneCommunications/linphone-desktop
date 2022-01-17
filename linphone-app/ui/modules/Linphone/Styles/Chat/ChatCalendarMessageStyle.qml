pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatCalendarMessage'
	property int heightMargin:  5
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
			property int pointSize: Units.dp * 10
			property string icon : 'schedule_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_schedule', 'j').color
		}
		property QtObject subject: QtObject {
			property int spacing: 5
			property int pointSize: Units.dp * 11
			property color color: ColorsList.add(sectionName+'_subject', 'j').color
		}
		property QtObject participants: QtObject {
			property int spacing: 5
			property int pointSize: Units.dp * 10
			property string icon : 'calendar_participants_custom'
			property int iconSize: 30
			property color color: ColorsList.add(sectionName+'_participants', 'j').color
		}
		
		property QtObject organizer: QtObject {
			property color color: ColorsList.add(sectionName+'_conference_organizer', 'j').color
			property int pointSize: Units.dp * 10
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
