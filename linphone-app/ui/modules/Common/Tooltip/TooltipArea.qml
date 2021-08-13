import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

MouseArea {
	id: tooltipArea
	
	property alias text: tooltip.text
	property int delay: TooltipStyle.delay
	property bool force: false
	property var tooltipParent: parent
	property int maxWidth : tooltipParent.width
	
	property bool _visible: false
	property int hoveringCursor : Qt.PointingHandCursor
	property bool isClickable : true
	
	anchors.fill:parent
	
	hoverEnabled: true
	scrollGestureEnabled: true
	
	onContainsMouseChanged: _visible = containsMouse
	cursorShape: containsMouse ? hoveringCursor : Qt.ArrowCursor
	
	onPressed: mouse.accepted = false
	onWheel: {
		_visible = false
		wheel.accepted = false
	}
	onClicked:{
		console.log("Clicked")
		if(isClickable){
			if(tooltip.delay>0) {
				tooltip.oldDelay = tooltip.delay
				tooltip.delay = 0
			}
			tooltip.show(text, -1);
		}
		mouse.accepted = false
	}
	
	Tooltip {
		id: tooltip
		
		property int oldDelay : 0
		
		delay: tooltipArea.delay
		parent: tooltipParent
		visible: _visible || force
		width: Math.min(tooltip.implicitWidth, Math.max(tooltipArea.maxWidth, TooltipStyle.minWidth))
		
		
		//tooltipParent.width>TooltipStyle.minWidth?tooltipParent.width:TooltipStyle.minWidth
		
		timeout: -1
		
		// Workaround to always display tooltip.
		onVisibleChanged: {
			if (!visible && force) {
				tooltip.visible = true
			}
		}
		MouseArea{
			anchors.fill:parent
			visible: tooltipArea.isClickable
			onClicked : {
				tooltip.hide()
				tooltip.delay = tooltip.oldDelay
				mouse.accepted = false
			}
		}	
	}
}
