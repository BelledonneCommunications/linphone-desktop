pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'HistoryView'
	property QtObject bar: QtObject {
		property var backgroundColor: ColorsList.add(sectionName+'_bar_bg', 'e')
		property int avatarSize: 60
		property int height: 80
		property int leftMargin: 40
		property int rightMargin: 30
		property int spacing: 20
		
		property QtObject actions: QtObject {
			property int spacing: 40
			
			property QtObject call: QtObject {
				property int iconSize: 40
			}
			
			property QtObject del: QtObject {
				property int iconSize: 40
			}
			
			property QtObject edit: QtObject {
				property int iconSize: 40
			}
		}
		
		property QtObject description: QtObject {
			property var subtitleColor: ColorsList.add(sectionName+'_bar_description_subtitle', 'g')
			property var titleColor: ColorsList.add(sectionName+'_bar_description_title', 'j')
		}
	}
	
	property QtObject filters: QtObject {
		property var backgroundColor: ColorsList.add(sectionName+'_filters_bg', 'q')
		property int height: 51
		property int leftMargin: 40
		
		property QtObject border: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_filters_border', 'g10')
			property int bottomWidth: 1
			property int topWidth: 0
		}
	}
	property QtObject videoCall: QtObject {
		property int iconSize: 40
		property string name : 'videoCall'
		property string icon : 'video_call_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject call: QtObject {
		property int iconSize: 40
		property string name : 'call'
		property string icon : 'call_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
	property QtObject deleteAction: QtObject {
		property int iconSize: 40
		property string name : 'delete'
		property string icon : 'delete_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
	}
	property QtObject chat: QtObject {
		property int iconSize: 40
		property string name : 'chat'
		property string icon : 'chat_custom'
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg')
	}
}
