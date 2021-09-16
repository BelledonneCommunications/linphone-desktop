pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'ContactEdit'
	property QtObject buttons: QtObject {
		property int spacing: 20
		property int topMargin: 20
	}
	
	property QtObject bar: QtObject {
		property color color: ColorsList.add(sectionName+'_bar', 'e').color
		property int avatarSize: 60
		property int height: 80
		property int leftMargin: 40
		property int rightMargin: 30
		property int spacing: 20
		
		property QtObject actions: QtObject {
			property int spacing: 40
			
			property QtObject del: QtObject {
				property int iconSize: 36
				property QtObject colorSet: QtObject {
					property int iconSize: 36
					property string name : 'delete'
					property string icon : 'contact_delete_custom'
					property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
					property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
					property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
					property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
					property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
					property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
				}
			}
			
			property QtObject edit: QtObject {
				property int iconSize: 36
				property QtObject colorSet: QtObject {
					property int iconSize: 36
					property string name : 'edit'
					property string icon : 'contact_edit_custom'
					property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_n_b_bg').color
					property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_h_b_bg').color
					property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg').color
					property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_n_b_fg').color
					property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_h_b_fg').color
					property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg').color
				}
			}
			
			property QtObject history: QtObject {
				property int iconSize: 40
			}
		}
		property QtObject avatarTakePicture: QtObject {
			property int iconSize: 60
			property string icon : 'contact_card_photo_custom'
			property string name : 'avatarTakePicture'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_h_b_bg').color
			property color backgroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_d', icon, 's_d_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_n_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_h_b_fg').color
			property color foregroundDisabledColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_d', icon, 's_d_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_n_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
		}
		
		property QtObject buttons: QtObject {
			property int size: 40
			property int spacing: 20
		}
		
		property QtObject username: QtObject {
			property color color: ColorsList.add(sectionName+'_username', 'j').color
			property int pointSize: Units.dp * 13
		}
	}
	
	property QtObject content: QtObject {
		property color color: ColorsList.add(sectionName+'_content', 'k').color
	}
	
	property QtObject values: QtObject {
		property int bottomMargin: 20
		property int leftMargin: 40
		property int rightMargin: 20
		property int topMargin: 20
		
		property QtObject separator: QtObject {
			property color color: ColorsList.add(sectionName+'_separator', 'f').color
			property int height: 1
		}
	}
	property QtObject chat: QtObject {
		property int iconSize: 40
		property string name : 'chat'
		property string icon : 'chat_custom'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
	property QtObject history: QtObject {
		property int iconSize: 40
		property string icon : 'history_custom'
		property string name : 'history'
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 's_p_b_fg').color
	}
}
