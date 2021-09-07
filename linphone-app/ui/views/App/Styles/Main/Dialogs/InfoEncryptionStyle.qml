pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property int height: 353
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 10
		property int rightMargin: 10
		property int spacing: 0
	}
	
	property QtObject okButton : QtObject{
		property QtObject backgroundColor: QtObject {
			property color disabled: ColorsList.add("InfoEncryption_ok_background_disabled", "i30").color
			property color hovered: ColorsList.add("InfoEncryption_ok_background_hovered", "b").color
			property color normal: ColorsList.add("InfoEncryption_ok_background_normal", "s").color
			property color pressed: ColorsList.add("InfoEncryption_ok_background_pressed", "m").color
		}
		
		property QtObject textColor: QtObject {
			property color disabled: ColorsList.add("InfoEncryption_ok_text_disabled", "q").color
			property color hovered: ColorsList.add("InfoEncryption_ok_text_hovered", "q").color
			property color normal: ColorsList.add("InfoEncryption_ok_text_normal", "q").color
			property color pressed: ColorsList.add("InfoEncryption_ok_text_pressed", "q").color
		}
	}
	
	property QtObject securityIcon: QtObject{
		property int iconSize: 40
		property int preferredHeight: 50
		property int preferredWidth: 50
	}
	
	property QtObject descriptionText: QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		property real pointSize: Units.dp * 11
		property color color: ColorsList.add("InfoEncryption_description", "d").color
	}
}