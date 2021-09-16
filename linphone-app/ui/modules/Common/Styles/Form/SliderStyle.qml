pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Slider'
	property QtObject background: QtObject {
		property color color: ColorsList.add(sectionName+'_bg', 'c').color
		property int height: 4
		property int radius: 2
		property int width: 200
		
		property QtObject content: QtObject {
			property color color: ColorsList.add(sectionName+'_content', 'm').color
			property int radius: 2
		}
	}
	
	property QtObject handle: QtObject {
		property int height: 16
		property int radius: 13
		property int width: 16
		
		property QtObject border: QtObject {
			property QtObject color: QtObject {
				property color normal: ColorsList.add(sectionName+'_handle_border_n', 'c').color
				property color pressed: ColorsList.add(sectionName+'_handle_border_p', 'c').color
			}
		}
		
		property QtObject color: QtObject {
			property color normal: ColorsList.add(sectionName+'_handle_n', 'e').color
			property color pressed: ColorsList.add(sectionName+'_handle_p', 'f').color
		}
	}
}
