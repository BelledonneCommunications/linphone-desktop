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
	property bool bindToEnd: false
	property bool endIsDisplayed: !vScrollBar.visible ||( vScrollBar.visualPosition + vScrollBar.visualSize) >= 1.0
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
	onBindToEndChanged: if(bindToEnd) positionViewAtEnd()
	onContentHeightChanged: {
		if(fitCacheToContent)
			cacheBuffer= (view.contentHeight > 0 ? view.contentHeight : 0)
		if(bindToEnd) positionViewAtEnd()
	}
	cacheBuffer: height > 0 ? height : 0
	// ---------------------------------------------------------------------------
	
	// TODO: Find a solution at this bug =>
	// https://bugreports.qt.io/browse/QTBUG-31573
	// https://bugreports.qt.io/browse/QTBUG-49989
}
