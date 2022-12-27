pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TabButton'
	property int spacing: 8
	
	property QtObject backgroundColor: QtObject {
		property var disabled: ColorsList.add(sectionName+'_bg_d', 'i30')
		property var hovered: ColorsList.add(sectionName+'_bg_h', 'b')
		property var normal: ColorsList.add(sectionName+'_bg_n', 'i')
		property var pressed: ColorsList.add(sectionName+'_bg_p', 'm')
		property var selected: ColorsList.add(sectionName+'_bg_c', 'k')
	}
	
	property QtObject icon: QtObject {
		property int size: 20
		property string sipAccountsIcon: 'settings_sip_accounts_custom'
		property string audioIcon: 'settings_audio_custom'
		property string videoIcon: 'settings_video_custom'
		property string callIcon: 'settings_call_custom'
		property string networkIcon: 'settings_network_custom'
		property string advancedIcon: 'settings_advanced_custom'
	}
	
	property QtObject text: QtObject {
		property int pointSize: Units.dp * 9
		property int height: 40
		property int leftPadding: 10
		property int rightPadding: 10
		
		property QtObject color: QtObject {
			property var disabled: ColorsList.add(sectionName+'_text_d', 'q')
			property var hovered: ColorsList.add(sectionName+'_text_h', 'q')
			property var normal: ColorsList.add(sectionName+'_text_n', 'q')
			property var pressed: ColorsList.add(sectionName+'_text_p', 'q')
			property var selected: ColorsList.add(sectionName+'_text_c', 'i')
		}
	}
}
