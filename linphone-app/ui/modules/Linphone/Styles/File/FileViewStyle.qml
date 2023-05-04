pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

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
		property int pointSize: Units.dp * 7
	}
	
	property QtObject download: QtObject{
		property string icon: 'download_custom'
		property int height: 20
		property int pointSize: Units.dp * 8
		property int iconSize: 30
		property var outgoingColor: ColorsList.addImageColor(sectionName+'_download_out', icon, 'g')
		property var incomingColor: ColorsList.addImageColor(sectionName+'_download_in', icon, 'q')
	}
	property QtObject thumbnailVideoIcon: QtObject {
		property int iconSize: 40
		property string name : 'play'
		property string icon : 'thumbnail_video_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'wr_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'wr_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'wr_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'wr_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'wr_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'wr_p_b_fg')
	}
	property QtObject animation: QtObject {
		property int duration: 300
		property real to: 1.7
		property real thumbnailTo: 2
	}
	
	property QtObject extension: QtObject {
		property string icon: 'file_extension_custom'
		property string imageIcon: 'file_image_custom'
		property int iconSize: 60
		property int internalSize: 37
		property int radius: 0
		
		property QtObject background: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_file_extension_bg', 'q')
			property var borderColorModel: ColorsList.add(sectionName+'_file_extension_border', 'extension_file_border')
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_file_extension_text', 'd')
			property int pointSize: Units.dp * 9
		}
	}
	
	property QtObject status: QtObject {
		property int spacing: 4
		
		property QtObject bar: QtObject {
			property int height: 6
			property int radius: 3
			
			property QtObject background: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_file_statusbar_bg', 'f')
			}
			
			property QtObject contentItem: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_file_statusbar_content', 'p')
			}
		}
	}
}
