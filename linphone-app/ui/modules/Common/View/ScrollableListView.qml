import QtQuick 2.12	//synchronousDrag
import QtQuick.Controls 2.2

import Common 1.0

// =============================================================================

ListView {
	id: view
	property bool hideScrollBars: false
	property alias verticalScrollPolicy : vScrollBar.policy
	property alias horizontalScrollPolicy : hScrollBar.policy
	
	function getVisibleIndex(checkMax) {
		var center_x = view.x + view.width / 2
		var index = -1
		var yCheck = 0
		var direction = checkMax ? -1 : 1
		var yStart = view.y + view.contentY + (checkMax ? view.height : 0)
		var yStep = 5
		while(index<0 && yCheck < view.height){
			index = indexAt( center_x, yStart + yCheck * direction)
			yCheck += yStep
		}
		return index
	}
	function getVisibleIndexRange() {
		return [getVisibleIndex(0), getVisibleIndex(1)]
	}
	function isIndexVisible(index){
		return getVisibleIndex(0) <= index && index <= getVisibleIndex(1)
	}
	function isIndexAfter(index){
		return getVisibleIndex(1) < index
	}
	
	// ---------------------------------------------------------------------------
	
	ScrollBar.vertical: ForceScrollBar {
		id: vScrollBar
		onPressedChanged: pressed ? view.movementStarted() : view.movementEnded()
		// ScrollBar.AsNeeded doesn't work. Do it ourself.
		policy: ScrollBar.AlwaysOff
		function updatePolicy(){
			policy = (view.orientation == Qt.Vertical && view.contentHeight > view.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff)
		}
		Timer{// Delay to avoid binding loops
			id:delayUpdateVPolicy
			interval:10
			onTriggered: vScrollBar.updatePolicy()
		}
		Component.onCompleted: if(!hideScrollBars) updatePolicy()
	}
	ScrollBar.horizontal: ForceScrollBar {
		id: hScrollBar
		
		onPressedChanged: pressed ? view.movementStarted() : view.movementEnded()
		// ScrollBar.AsNeeded doesn't work. Do it ourself.
		policy: ScrollBar.AlwaysOff
		function updatePolicy() {
			policy = (view.orientation == Qt.Horizontal && view.contentWidth > view.width? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff)
		}
		Timer{// Delay to avoid binding loops
			id:delayUpdateHPolicy
			interval:10
			onTriggered: hScrollBar.updatePolicy()
		}
		Component.onCompleted: if(!hideScrollBars) updatePolicy()
	}
	// ---------------------------------------------------------------------------
	boundsMovement: Flickable.StopAtBounds
	boundsBehavior: Flickable.DragOverBounds
	clip: true
	contentWidth: width - (vScrollBar.visible?vScrollBar.width:0)
	contentHeight: height - (hScrollBar.visible?hScrollBar.height:0)
	spacing: 0
	synchronousDrag: true
	onContentHeightChanged: {
		cacheBuffer= (view.contentHeight > 0 ? view.contentHeight : 0)
		if(!hideScrollBars)
			delayUpdateVPolicy.restart()
	}
	onHeightChanged: {
		if(!hideScrollBars)
			delayUpdateVPolicy.restart()
	}
	onContentWidthChanged: if(!hideScrollBars) delayUpdateHPolicy.restart()
	onWidthChanged: if(!hideScrollBars) delayUpdateHPolicy.restart()
	cacheBuffer: height > 0 ? height : 0
	// ---------------------------------------------------------------------------
	
	// TODO: Find a solution at this bug =>
	// https://bugreports.qt.io/browse/QTBUG-31573
	// https://bugreports.qt.io/browse/QTBUG-49989
}
