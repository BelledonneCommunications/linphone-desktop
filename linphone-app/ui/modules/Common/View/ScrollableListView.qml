import QtQuick 2.12	//synchronousDrag
import QtQuick.Controls 2.2

import Common 1.0

// =============================================================================

ListView {
	id: view
	
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
		policy: (view.contentHeight > view.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff)
	}
	// ---------------------------------------------------------------------------
	
	boundsBehavior: Flickable.StopAtBounds
	clip: true
	contentWidth: width - (vScrollBar.visible?vScrollBar.width:0)
	spacing: 0
	synchronousDrag: true
	cacheBuffer: height
	// ---------------------------------------------------------------------------
	
	// TODO: Find a solution at this bug =>
	// https://bugreports.qt.io/browse/QTBUG-31573
	// https://bugreports.qt.io/browse/QTBUG-49989
}
