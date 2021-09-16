pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TabButton'
	property int spacing: 8
	
	property QtObject backgroundColor: QtObject {
		property color disabled: ColorsList.add(sectionName+'_bg_d', 'i30').color
		property color hovered: ColorsList.add(sectionName+'_bg_h', 'b').color
		property color normal: ColorsList.add(sectionName+'_bg_n', 'i').color
		property color pressed: ColorsList.add(sectionName+'_bg_p', 'm').color
		property color selected: ColorsList.add(sectionName+'_bg_c', 'k').color
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
			property color disabled: ColorsList.add(sectionName+'_text_d', 'q').color
			property color hovered: ColorsList.add(sectionName+'_text_h', 'q').color
			property color normal: ColorsList.add(sectionName+'_text_n', 'q').color
			property color pressed: ColorsList.add(sectionName+'_text_p', 'q').color
			property color selected: ColorsList.add(sectionName+'_text_c', 'i').color
		}
	}
}
