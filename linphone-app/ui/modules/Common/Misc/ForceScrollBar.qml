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
	
	onContentSizeTargetChanged: Qt.callLater( scrollBar.updatePolicy)
	onSizeTargetChanged:  Qt.callLater( scrollBar.updatePolicy)
	
	policy: ScrollBar.AlwaysOff
	function updatePolicy(){
		policy = contentSizeTarget > sizeTarget ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
	}
	function delayPolicy(){
		Qt.callLater( scrollBar.updatePolicy)
	}
	Component.onCompleted: updatePolicy()
	
	
	background: Rectangle {
		anchors.fill: parent
		color: ForceScrollBarStyle.background.colorModel.color
		radius: ForceScrollBarStyle.background.radius
	}
	contentItem: Rectangle {
		color: scrollBar.pressed
			   ? ForceScrollBarStyle.color.pressed.color
			   : (scrollBar.hovered
				  ? ForceScrollBarStyle.color.hovered.color
				  : ForceScrollBarStyle.color.normal.color
				  )
		implicitHeight: ForceScrollBarStyle.contentItem.implicitHeight
		implicitWidth: ForceScrollBarStyle.contentItem.implicitWidth
		radius: ForceScrollBarStyle.contentItem.radius
	}
	hoverEnabled: true
}
