pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'OnlineInstallerDialog'
	property int height: 200
	property int width: 400
	
	property QtObject column: QtObject {
		property int spacing: 6
		
		property QtObject bar: QtObject {
			property int height: 20
			property int radius: 6
			
			property QtObject background: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_bar_bg', 'f')
			}
			
			property QtObject contentItem: QtObject {
				property QtObject color: QtObject {
					property var failed: ColorsList.add(sectionName+'_bar_content_failed', 'error')
					property var normal: ColorsList.add(sectionName+'_bar_content_n', 'p')
				}
			}
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_text', 'd')
			property int pointSize: Units.dp * 11
		}
	}
}
