pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0

// =============================================================================
QtObject {
	property int height: 320
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 10
		property int rightMargin: 10
		property int spacing: 0
	}
		
	property QtObject timer: QtObject {
		property int iconSize: 40
		property int preferredHeight: 50
		property int preferredWidth: 50
	}
	property QtObject descriptionText: QtObject {
		property int leftMargin: 10
		property int rightMargin: 10
		property real pointSize: Units.dp * 11
		property color color: Colors.d.color
	}
	property QtObject timerPicker: QtObject {
		property int preferredWidth: 150
		property int topMargin: 10
		property int bottomMargin: 10
	}
}