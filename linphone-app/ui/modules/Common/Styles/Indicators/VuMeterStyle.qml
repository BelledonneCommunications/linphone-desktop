pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'VuMeter'
	property int height: 40
	property int width: 5
	
	property QtObject high: QtObject {
		property QtObject background: QtObject {
			property QtObject color: QtObject {
				property var disabled:  ColorsList.add(sectionName+'_bg_d', 'o')
				property var enabled: ColorsList.add(sectionName+'_bg_enabled', 'n')
			}
		}
		
		property QtObject contentItem: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_contentItem', 'b')
		}
	}
	
	property QtObject low: QtObject {
		property QtObject background: QtObject {
			property QtObject color: QtObject {
				property var disabled: ColorsList.add(sectionName+'_low_bg_d', 'o')
				property var enabled: ColorsList.add(sectionName+'_low_bg_enabled', 'n')
			}
		}
		
		property QtObject contentItem: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_low_contentItem', 'j')
		}
	}
}
