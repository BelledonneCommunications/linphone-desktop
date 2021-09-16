pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'CallsWindow'
	property int minimumHeight: 480
	property int minimumWidth: 960
	
	property QtObject call: QtObject {
		property int minimumWidth: 395
	}
	
	property QtObject callsList: QtObject {
		property color color: ColorsList.add(sectionName+'_list_bg', 'q').color
		property int defaultWidth: 250
		property int maximumWidth: 250
		property int minimumWidth: 110
		
		property QtObject header: QtObject {
			property color color1: ColorsList.add(sectionName+'_list_header_a', 'q').color
			property color color2: ColorsList.add(sectionName+'_list_header_b', 'f').color
			property int height: 60
			property int iconSize: 40
			property int leftMargin: 10
		}
		property QtObject newCall: QtObject {
			property int iconSize: 40
			property string name : 'newCall'
			property string icon : 'new_call_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg').color
		}
		property QtObject newConference: QtObject {
			property int iconSize: 40
			property string name : 'newConference'
			property string icon : 'new_conference_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'ma_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'ma_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'ma_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'ma_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'ma_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'ma_p_b_fg').color
		}
	}
	
	property QtObject chat: QtObject {
		property int minimumWidth: 300
	}
}
