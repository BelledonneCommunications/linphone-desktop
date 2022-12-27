pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Slider'
	property QtObject background: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_bg', 'c')
		property int height: 4
		property int radius: 2
		property int width: 200
		
		property QtObject content: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_content', 'm')
			property int radius: 2
		}
	}
	
	property QtObject handle: QtObject {
		property int height: 16
		property int radius: 13
		property int width: 16
		
		property QtObject border: QtObject {
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_handle_border_n', 'c')
				property var pressed: ColorsList.add(sectionName+'_handle_border_p', 'c')
			}
		}
		
		property QtObject color: QtObject {
			property var normal: ColorsList.add(sectionName+'_handle_n', 'e')
			property var pressed: ColorsList.add(sectionName+'_handle_p', 'f')
		}
	}
}
