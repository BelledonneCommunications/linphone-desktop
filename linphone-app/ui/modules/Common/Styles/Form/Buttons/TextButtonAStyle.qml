pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property QtObject backgroundColor: QtObject {
		property color disabled: ColorsList.add("TextButton_background_disabled", "o").color
		property color hovered: ColorsList.add("TextButton_background_hovered", "j").color
		property color normal: ColorsList.add("TextButton_background_normal", "r").color
		property color pressed: ColorsList.add("TextButton_background_pressed", "i").color
	}
	
	property QtObject textColor: QtObject {
		property color disabled: ColorsList.add("TextButton_text_disabled", "q").color
		property color hovered: ColorsList.add("TextButton_text_hovered", "q").color
		property color normal: ColorsList.add("TextButton_text_normal", "q").color
		property color pressed: ColorsList.add("TextButton_text_pressed", "q").color
	}
	property QtObject borderColor : backgroundColor
}
