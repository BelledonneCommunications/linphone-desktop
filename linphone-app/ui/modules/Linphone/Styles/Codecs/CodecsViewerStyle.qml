pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CodecsViewer'
	property int leftMargin: 10
	
	property QtObject attribute: QtObject {
		property int height: 40
		
		property QtObject background: QtObject {
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_n', 'a')
				property var hovered: ColorsList.add(sectionName+'_h', 'o')
			}
		}
		
		property QtObject dropArea: QtObject {
			property int margins: 5
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_text', 'j')
			property int pointSize: Units.dp * 10
		}
	}
	
	property QtObject column: QtObject {
		property int bitrateWidth: 120
		property int clockRateWidth: 100
		property int encoderDescriptionWidth: 280
		property int mimeWidth: 100
		property int recvFmtpWidth: 200
		property int spacing: 10
	}
	
	property QtObject legend: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_legend', 'j')
		property int pointSize: Units.dp * 10
		property int height: 50
	}
}
