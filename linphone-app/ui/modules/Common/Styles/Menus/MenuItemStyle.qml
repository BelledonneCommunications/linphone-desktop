pragma Singleton
import QtQml 2.2
import QtQuick 2.3

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'MenuItem'
	
	property QtObject speaker: QtObject {
		property int iconSize: 30
		property string icon : 'speaker_on_custom'
	}
	property QtObject copy: QtObject {
		property int iconSize: 30
		property string icon : 'menu_copy_text_custom'
	}
	property QtObject reply: QtObject {
		property int iconSize: 30
		property string icon : 'menu_reply_custom'
	}
	property QtObject forward: QtObject {
		property int iconSize: 30
		property string icon : 'menu_forward_custom'
	}
	property QtObject imdn: QtObject {
		property int iconSize: 30
		property string icon : 'menu_imdn_info_custom'
	}
	property QtObject deleteEntry: QtObject {
		property int iconSize: 30
		property string icon : 'delete_custom'
	}
	property QtObject info: QtObject {
		property int iconSize: 20
		property string icon : 'menu_info_custom'
	}
	property QtObject devices: QtObject {
		property string icon : 'menu_devices_custom'
	}
	property QtObject ephemeral: QtObject {
		property string icon : 'menu_ephemeral_custom'
	}
	property QtObject scheduleMeeting: QtObject {
		property string icon : 'meetings_custom'
	}
	
	property QtObject contact: QtObject {
		property string add : 'contact_add_custom'
		property string view : 'contact_view_custom'
	}
	
	
	property QtObject normal : QtObject{
		property int leftMargin: 5
		property int rightMargin: 5
		
		property QtObject background: QtObject {
			property int height: 30
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_normal_bg_h', 'o').color
				property color normal: ColorsList.add(sectionName+'_normal_bg_n', 'q').color
				property color pressed: ColorsList.add(sectionName+'_normal_bg_p', 'o').color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Bold
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_n_text_h', 'j').color
				property color normal: ColorsList.add(sectionName+'_n_text_n', 'j').color
				property color pressed: ColorsList.add(sectionName+'_n_text_p', 'j').color
				property color disabled: ColorsList.add(sectionName+'_n_text_d', 'l50').color
			}
		}
	}
	property QtObject aux : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux_bg_h', 'v').color
				property color normal: ColorsList.add(sectionName+'_aux_bg_n', 'a').color
				property color pressed: ColorsList.add(sectionName+'_aux_bg_p', 'v').color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux_text_h', 'j').color
				property color normal: ColorsList.add(sectionName+'_aux_text_n', 'j').color
				property color pressed: ColorsList.add(sectionName+'_aux_text_p', 'j').color
				property color disabled: ColorsList.add(sectionName+'_aux_text_d', 'l50').color
			}
		}
	}
	property QtObject auxError : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_auxRed_bg_h', 'v').color
				property color normal: ColorsList.add(sectionName+'_auxRed_bg_n', 'a').color
				property color pressed: ColorsList.add(sectionName+'_auxRed_bg_p', 'v').color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_auxError_text_h', 'error').color
				property color normal: ColorsList.add(sectionName+'_auxError_text_n', 'error').color
				property color pressed: ColorsList.add(sectionName+'_auxError_text_p', 'error').color
				property color disabled: ColorsList.add(sectionName+'_auxError_text_d', 'l50').color
			}
		}
	}
	property QtObject aux2 : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 50
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux2_bg_h', 'w').color
				property color normal: ColorsList.add(sectionName+'_aux2_bg_n', 'w').color
				property color pressed: ColorsList.add(sectionName+'_aux2_bg_p', 'v').color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux2_text_h', 'm').color
				property color normal: ColorsList.add(sectionName+'_aux2_text_n', 'j').color
				property color pressed: ColorsList.add(sectionName+'_aux2_text_p', 'm').color
				property color disabled: ColorsList.add(sectionName+'_aux2_text_d', 'l50').color
			}
		}
	}
	property QtObject aux2Error : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 50
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux2Error_bg_h', 'w').color
				property color normal: ColorsList.add(sectionName+'_aux2Error_bg_n', 'w').color
				property color pressed: ColorsList.add(sectionName+'_aux2Error_bg_p', 'v').color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add(sectionName+'_aux2Error_text_h', 'error').color
				property color normal: ColorsList.add(sectionName+'_aux2Error_text_n', 'error').color
				property color pressed: ColorsList.add(sectionName+'_aux2Error_text_p', 'error').color
				property color disabled: ColorsList.add(sectionName+'_aux2Error_text_d', 'l50').color
			}
		}
	}
}
