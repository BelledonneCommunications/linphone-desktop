import QtQuick 2.7
import QtQuick.Controls 2.2

import Common.Styles 1.0

// =============================================================================
// A simple custom vertical scrollbar.
// =============================================================================

ScrollBar {
	id: scrollBar
	property int contentSizeTarget
	property int sizeTarget
	
	onContentSizeTargetChanged: delayUpdatePolicy.restart()
	onSizeTargetChanged:  delayUpdatePolicy.restart()
	
	policy: ScrollBar.AlwaysOff
	function updatePolicy(){
		policy = contentSizeTarget > sizeTarget ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
	}
	function delayPolicy(){
		delayUpdatePolicy.restart()
	}
	Component.onCompleted: updatePolicy()
	Timer{// Delay to avoid binding loops
		id:delayUpdatePolicy
		interval:10
		onTriggered: scrollBar.updatePolicy()
	}
	
	background: Rectangle {
		anchors.fill: parent
		color: ForceScrollBarStyle.background.color
		radius: ForceScrollBarStyle.background.radius
	}
	contentItem: Rectangle {
		color: scrollBar.pressed
			   ? ForceScrollBarStyle.color.pressed
			   : (scrollBar.hovered
				  ? ForceScrollBarStyle.color.hovered
				  : ForceScrollBarStyle.color.normal
				  )
		implicitHeight: ForceScrollBarStyle.contentItem.implicitHeight
		implicitWidth: ForceScrollBarStyle.contentItem.implicitWidth
		radius: ForceScrollBarStyle.contentItem.radius
	}
	hoverEnabled: true
}
