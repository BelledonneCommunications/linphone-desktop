pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'MultimediaParamsDialog'
	property int height: 350
	property int width: 450
	
	property QtObject column: QtObject {
		property int spacing: 15
		
		property QtObject entry: QtObject {
			property int iconSize: 24
			property int spacing: 10
			property int spacing2: 5
			property QtObject speaker: QtObject {
				property int iconSize: 30
				property string icon : 'speaker_on_custom'
				property string name : 'speaker'
				property var colorModel : ColorsList.addImageColor(sectionName+'_'+name, icon, 'g')
			}
			property QtObject micro: QtObject {
				property int iconSize: 30
				property string icon : 'micro_on_custom'
				property string name : 'micro'
				property var colorModel : ColorsList.addImageColor(sectionName+'_'+name, icon, 'g')
			}
			property QtObject camera: QtObject {
				property int iconSize: 30
				property string icon : 'camera_on_custom'
				property string name : 'camera'
				property var colorModel : ColorsList.addImageColor(sectionName+'_'+name, icon, 'g')
			}
		}
	}
	
}
