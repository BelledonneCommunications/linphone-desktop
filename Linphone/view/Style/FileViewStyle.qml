pragma Singleton
import QtQml

import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================

QtObject {
	property string sectionName : 'FileView'
	
	property int height: 120
	property int heightbetter: 200
	property int iconSize: 18
	property int margins: 8
	property int spacing: 8
	property int width: 100
	
	property QtObject name: QtObject{
		property int pointSize: Utils.getSizeWithScreenRatio(7)
	}
	
	property QtObject download: QtObject{
		property string icon: AppIcons.download
		property int height: 20
		property int pointSize: Utils.getSizeWithScreenRatio(8)
		property int iconSize: 30
	}
	property QtObject thumbnailVideoIcon: QtObject {
		property int iconSize: 40
		property string name : 'play'
		property string icon : AppIcons.playFill
	}
	property QtObject animation: QtObject {
		property int duration: 300
		property real to: 1.7
		property real thumbnailTo: 2
	}
	
	property QtObject extension: QtObject {
		property string icon: AppIcons.file
		property string imageIcon: AppIcons.fileImage
		property int iconSize: 60
		property int internalSize: 37
		property int radius: Utils.getSizeWithScreenRatio(5)
		
		property QtObject background: QtObject {
			property var color: DefaultStyle.grey_0
			property var borderColor: DefaultStyle.grey_0
		}
		
		property QtObject text: QtObject {
			property var color: DefaultStyle.grey_0
			property int pointSize: Utils.getSizeWithScreenRatio(9)
		}
	}
	
	property QtObject status: QtObject {
		property int spacing: 4
		
		property QtObject bar: QtObject {
			property int height: 6
			property int radius: 3
			
			property QtObject background: QtObject {
				property var color: DefaultStyle.grey_0
			}
			
			property QtObject contentItem: QtObject {
				property var color: DefaultStyle.grey_0
			}
		}
	}
}
