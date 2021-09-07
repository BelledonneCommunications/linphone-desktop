pragma Singleton
import QtQml 2.2
import QtQuick 2.3

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property QtObject normal : QtObject{
		property int leftMargin: 5
		property int rightMargin: 5
		
		property QtObject background: QtObject {
			property int height: 30
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_normal_background_hovered", "o").color
				property color normal: ColorsList.add("MenuItem_normal_background_normal", "q").color
				property color pressed: ColorsList.add("MenuItem_normal_background_pressed", "o").color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Bold
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_normal_text_hovered", "j").color
				property color normal: ColorsList.add("MenuItem_normal_text_normal", "j").color
				property color pressed: ColorsList.add("MenuItem_normal_text_pressed", "j").color
				property color disabled: ColorsList.add("MenuItem_normal_text_disabled", "l50").color
			}
		}
	}
	property QtObject aux : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_aux_background_hovered", "v").color
				property color normal: ColorsList.add("MenuItem_aux_background_normal", "a").color
				property color pressed: ColorsList.add("MenuItem_aux_background_pressed", "v").color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_aux_text_hovered", "j").color
				property color normal: ColorsList.add("MenuItem_aux_text_normal", "j").color
				property color pressed: ColorsList.add("MenuItem_aux_text_pressed", "j").color
				property color disabled: ColorsList.add("MenuItem_aux_text_disabled", "l50").color
			}
		}
	}
	property QtObject auxRed : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 40
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_auxRed_background_hovered", "v").color
				property color normal: ColorsList.add("MenuItem_auxRed_background_normal", "a").color
				property color pressed: ColorsList.add("MenuItem_auxRed_background_pressed", "v").color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_auxRed_text_hovered", "error").color
				property color normal: ColorsList.add("MenuItem_auxRed_text_normal", "error").color
				property color pressed: ColorsList.add("MenuItem_auxRed_text_pressed", "error").color
				property color disabled: ColorsList.add("MenuItem_auxRed_text_disabled", "l50").color
			}
		}
	}
	property QtObject aux2 : QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		
		property QtObject background: QtObject {
			property int height: 50
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_aux2_background_hovered", "w").color
				property color normal: ColorsList.add("MenuItem_aux2_background_normal", "w").color
				property color pressed: ColorsList.add("MenuItem_aux2_background_pressed", "v").color
			}
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 11
			property int weight : Font.Normal
			
			property QtObject color: QtObject {
				property color hovered: ColorsList.add("MenuItem_aux2_text_hovered", "m").color
				property color normal: ColorsList.add("MenuItem_aux2_text_normal", "j").color
				property color pressed: ColorsList.add("MenuItem_aux2_text_pressed", "m").color
				property color disabled: ColorsList.add("MenuItem_aux2_text_disabled", "l50").color
			}
		}
	}
}
