import QtQuick 2.7

import Common 1.0
import Utils 1.0

import UtilsCpp 1.0

MouseArea{
	id: mainItem
	property bool realRunning : false
	property bool firstUse: true
	Timer {
		id: hideButtonsTimer
		interval: mainItem.firstUse ? 500 : 4000
		running: false
		triggeredOnStart: !mainItem.firstUse
		onTriggered: {if(!mainItem.firstUse && mainItem.realRunning != running) mainItem.realRunning = running
						mainItem.firstUse = false}
		function startTimer(){
			if(!mainItem.firstUse || !running)
				restart();
		}
		function stopTimer(){
			stop()
			mainItem.realRunning = false
			mainItem.firstUse = false
		}
	}

	acceptedButtons: Qt.NoButton
	propagateComposedEvents: true
	cursorShape: undefined
	//cursorShape: Qt.ArrowCursor
	onEntered: hideButtonsTimer.startTimer()
	onExited: {
		var cursorPosition = UtilsCpp.getCursorPosition()
		mapToItem(window.contentItem, cursorPosition.x, cursorPosition.y)
		if (cursorPosition.x <= 0 || cursorPosition.y <= 0
				|| cursorPosition.x >= width || cursorPosition.y >= height)
			hideButtonsTimer.stopTimer()
	}
	onPositionChanged: hideButtonsTimer.startTimer()
}