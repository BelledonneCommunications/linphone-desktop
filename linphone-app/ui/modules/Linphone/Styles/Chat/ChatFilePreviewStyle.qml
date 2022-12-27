pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'ChatFilePreview'
	property int height: 160
	
	property QtObject filePreview: QtObject{
		id: filePreviewObject
		property int heightMargins: 60
		property real format: 16/9
		
		property string name: 'filePreview'
		property string icon: 'menu_reply_custom'
		property var backgroundColor: ColorsList.add(sectionName+'_'+name+'_bg', 'e')
		property var headerTextColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i')
		property var iconColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i')
		property var textColor: ColorsList.add(sectionName+'_'+name+'_fg', 'd')
		property int pointSize: Units.dp * 9
		property int headerPointSize: Units.dp * 9
		property QtObject removeButton: QtObject{
			property int iconSize: 30
			property string name : 'remove'
			property string icon : 'close_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_n', icon, 's_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_h', icon, 's_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_p', icon, 's_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_n', icon, 's_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_h', icon, 's_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_p', icon, 's_p_b_fg')
		}
		property QtObject closeButton: QtObject{
			property int iconSize: 30
			property string name : 'close'
			property string icon : 'close_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_n', icon, 'l_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_b_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_n', icon, 'l_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+filePreviewObject.name+'_'+name+'_f_p', icon, 'l_p_b_fg')
		}
	}
}
