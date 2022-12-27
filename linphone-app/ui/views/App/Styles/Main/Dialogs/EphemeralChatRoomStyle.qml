pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property string sectionName: 'EphemeralChatRoom'
	property int height: 320
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 10
		property int rightMargin: 10
		property int spacing: 0
	}
		
	property QtObject timer: QtObject {
		property int iconSize: 60
		property int preferredHeight: 60
		property int preferredWidth: 60
		property string icon: 'timer_custom'
		property var timerColor: ColorsList.addImageColor(sectionName+'_timer', icon, 'ad')
	}
	property QtObject descriptionText: QtObject {
		property int preferredWidth: 200
		property int leftMargin: 10
		property int rightMargin: 10
		property real pointSize: Units.dp * 11
		property var colorModel: ColorsList.add(sectionName+'_popup_description', 'd')
	}
	property QtObject timerPicker: QtObject {
		property int preferredWidth: 150
		property int topMargin: 10
		property int bottomMargin: 10
	}
}