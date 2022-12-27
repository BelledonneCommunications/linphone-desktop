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
	property var colorModel: ColorsList.add(sectionName+'', 'telkeypad_bg')
	property var selectedColor : ColorsList.add(sectionName+'_c', 'm')
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
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'telkeypad_fg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'telkeypad_h')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'i')
			property var backgroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_u', icon, 'i')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'transparent')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'transparent')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'transparent')
			property var foregroundUpdatingColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_u', icon, 'transparent')
		}
		
		property QtObject line: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_b_line', 'l50')
			property int bottomMargin: 4
			property int height: 2
			property int leftMargin: 8
			property int rightMargin: 8
			property int topMargin: 0
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_b_text', 'telkeypad_bg')
			property int pointSize: Units.dp * 14
		}
	}
}
