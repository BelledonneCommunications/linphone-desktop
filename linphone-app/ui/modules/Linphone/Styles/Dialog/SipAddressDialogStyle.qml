pragma Singleton
import QtQml 2.2
import ColorsList 1.0
import Units 1.0
// =============================================================================

QtObject {
	property string sectionName : 'SipAddressDialog'
	property int height: 420
	property int spacing: 10
	property int width: 450
	
	property QtObject select: QtObject {
		property int iconSize: 36
		property string icon : 'transfer_custom'
		property string name : 'select'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject searchField: QtObject {
		property color color: ColorsList.add(sectionName+'_searchField', 'c').color
	}
	property QtObject list: QtObject {
		property color color: ColorsList.add(sectionName+'_list_title', 'g').color
		property int pointSize: Units.dp * 11
	}
}
