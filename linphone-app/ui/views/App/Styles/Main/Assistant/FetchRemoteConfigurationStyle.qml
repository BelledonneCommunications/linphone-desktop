pragma Singleton
import QtQml 2.2

import ColorsList 1.0
import Units 1.0
// =============================================================================

QtObject {
	property string sectionName: 'FetchRemoteConfiguration'
	
	property QtObject fieldTitles: QtObject{
		property int pointSize: Units.dp * 10
		property color color: ColorsList.add(sectionName+'_url_title', 'j').color
	}
	property QtObject qRCode : QtObject{
		property color borderColor: ColorsList.add(sectionName+'_qrcode_border', 'border_light').color
	}
	property QtObject explanationQRCode : QtObject{
		property int pointSize: Units.dp * 9
		property color color: ColorsList.add(sectionName+'_qrcode_text', 'j').color
	}
	
	property QtObject checkBox: QtObject {
		property int width: 300
	}
	property QtObject warningBlock: QtObject {
		property int spacing: 10
		property int pointSize: Units.dp * 10
		property color color: ColorsList.add(sectionName+'_description', 'g').color
		
		property QtObject contactUrl: QtObject {
			property color color: ColorsList.add(sectionName+'_url', 'i').color
			property int pointSize: Units.dp * 9
		}
	}
}
