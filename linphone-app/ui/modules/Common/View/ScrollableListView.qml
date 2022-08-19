import QtQuick 2.12	//synchronousDrag
import QtQuick.Controls 2.2

import Common 1.0

// =============================================================================

ListView {
	id: view
	property bool hideScrollBars: false
	property alias verticalScrollPolicy : vScrollBar.policy
	property alias horizontalScrollPolicy : hScrollBar.policy
	
	property bool fitCacheToContent: true
	
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
		contentSizeTarget: view.contentHeight
		sizeTarget: view.height
	}
	ScrollBar.horizontal: ForceScrollBar {
		id: hScrollBar
		
		onPressedChanged: pressed ? view.movementStarted() : view.movementEnded()
		contentSizeTarget: view.contentWidth
		sizeTarget: view.width
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
		if(fitCacheToContent)
			cacheBuffer= (view.contentHeight > 0 ? view.contentHeight : 0)
	}
	cacheBuffer: height > 0 ? height : 0
	// ---------------------------------------------------------------------------
	
	// TODO: Find a solution at this bug =>
	// https://bugreports.qt.io/browse/QTBUG-31573
	// https://bugreports.qt.io/browse/QTBUG-49989
}
