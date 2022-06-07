pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'TelKeypad'
	property int columnSpacing: 12
	property int height: 240
	property int rowSpacing: 12
	property int width: 240
	property color color: ColorsList.add(sectionName+'', 'telkeypad_bg').color
	property color selectedColor : ColorsList.add(sectionName+'_c', 'm').color
	property int selectedBorderWidth: 2
	property real radius : 20
	
	property QtObject voicemail: QtObject{
		property string icon: 'tel_keypad_voicemail_custom'
		property int iconSize: 20
	}
	
	property QtObject button: QtObject {
		property QtObject colorSet: QtObject{
			property int iconSize: 0
			property string name : 'telButton'
			property string icon : ''
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'telkeypad_fg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'telkeypad_h').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'i').color
			property color backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'i').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'transparent').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'transparent').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'transparent').color
			property color foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'transparent').color
		}
		
		property QtObject line: QtObject {
			property color color: ColorsList.add(sectionName+'_b_line', 'l50').color
			property int bottomMargin: 4
			property int height: 2
			property int leftMargin: 8
			property int rightMargin: 8
			property int topMargin: 0
		}
		
		property QtObject text: QtObject {
			property color color: ColorsList.add(sectionName+'_b_text', 'telkeypad_bg').color
			property int pointSize: Units.dp * 14
		}
	}
}
