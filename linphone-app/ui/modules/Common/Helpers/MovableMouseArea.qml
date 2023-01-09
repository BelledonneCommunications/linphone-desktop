import QtQuick 2.7

import Common 1.0
import Utils 1.0

MouseArea{
	id: mainItem
	property var movableArea: mainItem.Window.contentItem
	
	signal requestResetPosition()
	
	property bool dragging: drag.active
	onDraggingChanged: {
		if(dragging){
			xClicked = mouseX
			yClicked = mouseY
		}
		
	}
// Position buffer
	property int xClicked : 0
	property int yClicked : 0
// Scaling buffer
	property int heightOrigin
	property int widthOrigin
	property double startTime: 0	// For acceleration computation to avoid excessive wheel scrolling
	property double mScale: 1.0		// Using scale reduce quality. Apply our factor.
	property bool scaled : false	// Zoom state : -for storing origin state ; -for resetting scale on right click. In this case, second click lead to emit reset signal instead of first..
	
	acceptedButtons: Qt.LeftButton | Qt.RightButton	// Left is for Dragging. Right is for resetting. Wheel will scale.
	cursorShape: dragging ? Qt.DragMoveCursor : undefined
	preventStealing: true
	propagateComposedEvents: true
	hoverEnabled: true
	
	function updateScale(){// Avoid scaling if leading outside movableArea.
		drag.target.height = Math.max(0, Math.min(movableArea.height, heightOrigin * mScale))
		drag.target.width = Math.max(0, Math.min(movableArea.width, widthOrigin * mScale))
		updatePosition(0,0)
	}
	function updatePosition(x, y){// Avoid moving outside movableArea.
		var parentTLBounds = drag.target.parent.mapFromItem(movableArea, 0, 0);
		var parentBRBounds = drag.target.parent.mapFromItem(movableArea, movableArea.width, movableArea.height);
		drag.target.x = Math.max(parentTLBounds.x, Math.min(parentBRBounds.x - drag.target.width, drag.target.x + x))
		drag.target.y = Math.max(parentTLBounds.y, Math.min(parentBRBounds.y - drag.target.height, drag.target.y + y))
	}
	onMScaleChanged: updateScale()
	onPositionChanged: {
		if(dragging){
			updatePosition(mouse.x - xClicked, mouse.y - yClicked)
		}
		mouse.accepted = false
	}
	onWheel: {
		if(!scaled){
			scaled = true
			heightOrigin = drag.target.height
			widthOrigin = drag.target.width
		}
		var acceleration = 0.01;	// Try to make smoother the scaling from wheel
		if(startTime == 0){
			startTime = new Date().getTime();
		}else{
			var delay = new Date().getTime() - startTime;
			if(delay > 0)
				acceleration = Math.max(0.01, Math.min(1, 4/delay));
			else
				acceleration = 1
		}
		mScale = Math.max(0.5 , mScale * ( 1 + acceleration*(wheel.angleDelta.y >0 ? 1 : -1) ));
		startTime = new Date().getTime();
	}
	onClicked: {
		if(mouse.button == Qt.RightButton){
			if(scaled) {
				scaled = false
				mScale = 1.0
			}else
				requestResetPosition()
		}
		mouse.accepted = false
	}
}
