pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property int spacing: 8
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
	}
			
	property QtObject menu: QtObject{
		property string sectionName: 'TabButtonMenu'
		
		property QtObject backgroundColor: QtObject {
			property var disabled: ColorsList.add(menu.sectionName+'_bg_d', 'i30')
			property var hovered: ColorsList.add(menu.sectionName+'_bg_h', 'b')
			property var normal: ColorsList.add(menu.sectionName+'_bg_n', 'i')
			property var pressed: ColorsList.add(menu.sectionName+'_bg_p', 'm')
			property var selected: ColorsList.add(menu.sectionName+'_bg_c', 'k')
		}
		
		property QtObject text: QtObject {
			
			property QtObject color: QtObject {
				property var disabled: ColorsList.add(menu.sectionName+'_text_d', 'q')
				property var hovered: ColorsList.add(menu.sectionName+'_text_h', 'q')
				property var normal: ColorsList.add(menu.sectionName+'_text_n', 'q')
				property var pressed: ColorsList.add(menu.sectionName+'_text_p', 'q')
				property var selected: ColorsList.add(menu.sectionName+'_text_c', 'i')
			}
		}
		property var selector: ColorsList.add(menu.sectionName+'_selector', 'i')
	}
	property QtObject popup: QtObject{
		property string sectionName: 'TabButtonPopup'
		
		property QtObject backgroundColor: QtObject {
			property var disabled: ColorsList.add(popup.sectionName+'_bg_d', 'l10')
			property var hovered: ColorsList.add(popup.sectionName+'_bg_h', 'l20')
			property var normal: ColorsList.add(popup.sectionName+'_bg_n', 'a')
			property var pressed: ColorsList.add(popup.sectionName+'_bg_p', 'l30')
			property var selected: ColorsList.add(popup.sectionName+'_bg_c', 'a')
		}
		
		
		property QtObject text: QtObject {
			
			property QtObject color: QtObject {
				property var disabled: ColorsList.add(popup.sectionName+'_text_d', 'g')
				property var hovered: ColorsList.add(popup.sectionName+'_text_h', 'g')
				property var normal: ColorsList.add(popup.sectionName+'_text_n', 'g')
				property var pressed: ColorsList.add(popup.sectionName+'_text_p', 'g')
				property var selected: ColorsList.add(popup.sectionName+'_text_c', 'i')
			}
		}
		property var selector: ColorsList.add(popup.sectionName+'_selector', 'i')
	}
}
