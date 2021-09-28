pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property int height: 500
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 25
		property int rightMargin: 25
		property int spacing: 7
	}
	
	property QtObject searchBar : QtObject{
		property int topMargin : 10
	}
	
	property QtObject results : QtObject{
		property int topMargin : 10
		property color color : ColorsList.add("InfoChatRoom_results", "g").color
		property QtObject title : QtObject{
			property int topMargin: 10
			property int leftMargin: 20
			property color color: ColorsList.add("InfoChatRoom_results_title", "j").color
			property int pointSize : Units.dp * 11
			property int weight : Font.DemiBold
		}
		property QtObject header: QtObject{
			property int rightMargin: 55
			property color color: Colors.t.color
			property int weight : Font.Light
			property int pointSize : Units.dp * 10
			
		}
	}	
	
	property QtObject leaveButton : 
	QtObject {
		property QtObject backgroundColor: QtObject {
			property color disabled: ColorsList.add("InfoChatRoom_leave_background_disabled", "o").color
			property color hovered: ColorsList.add("InfoChatRoom_leave_background_hovered", "j").color
			property color normal: ColorsList.add("InfoChatRoom_leave_background_normal", "k").color
			property color pressed: ColorsList.add("InfoChatRoom_leave_background_pressed", "i").color
		}
		
		property QtObject textColor: QtObject {
			property color disabled: ColorsList.add("InfoChatRoom_leave_text_disabled", "q").color
			property color hovered: ColorsList.add("InfoChatRoom_leave_text_hovered", "q").color
			property color normal: ColorsList.add("InfoChatRoom_leave_text_normal", "i").color
			property color pressed: ColorsList.add("InfoChatRoom_leave_text_pressed", "q").color
		}
		property QtObject borderColor : QtObject{
			property color disabled: ColorsList.add("InfoChatRoom_leave_border_disabled", "q").color
			property color hovered: ColorsList.add("InfoChatRoom_leave_border_hovered", "q").color
			property color normal: ColorsList.add("InfoChatRoom_leave_border_normal", "i").color
			property color pressed: ColorsList.add("InfoChatRoom_leave_border_pressed", "q").color
		}
	}
}