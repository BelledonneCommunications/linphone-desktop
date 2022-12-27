import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
	id: wrapper
	
	property bool isOpen : popup.visible || (!popup.visible && closeDelay.running) // This way, we prevent instant reopening on lost focus with clicked events
	property bool delayClosing : false
	// Optionnal parameters, set the position of popup relative to this item.
	property var relativeTo
	property int relativeX: 0
	property int relativeY: 0
	
	default property alias _content: popup.contentItem
	property alias closePolicy : popup.closePolicy
	property alias backgroundPopup: backgroundPopup.color
	property bool showShadow : true
	
	// ---------------------------------------------------------------------------
	
	signal closed
	signal opened
	
	// ---------------------------------------------------------------------------
	
	function open () {
		if (popup.visible) {
			return
		}
		
		if (relativeTo) {
			var parent = Utils.getTopParent(this)
			
			popup.x = Qt.binding(function () {
				return relativeTo ? relativeTo.mapToItem(null, relativeX, relativeY).x : 0
			})
			popup.y = Qt.binding(function () {
				return relativeTo ? relativeTo.mapToItem(null, relativeX, relativeY).y : 0
			})
		} else {
			popup.x = Qt.binding(function () {
				return x
			})
			popup.y = Qt.binding(function () {
				return y
			})
		}
		
		popup.open()
	}
	function close(){
		if (!popup.visible) {
			return
		}
		
		popup.x = 0
		popup.y = 0
		
		popup.close()
		
	}
	
	// ---------------------------------------------------------------------------
	
	visible: false
	
	// ---------------------------------------------------------------------------
	Timer{// This way, we prevent instant reopening on lost focus with clicked events
		id: closeDelay
		interval: 100
	}
	Controls.Popup {
		id: popup
		
		height: wrapper.height
		width: wrapper.width
		
		background: Rectangle {
			id: backgroundPopup
			color: PopupStyle.backgroundColor.color
			height: popup.height
			width: popup.width
			
			layer {
				enabled: wrapper.showShadow
				effect: PopupShadow {}
			}
		}
		
		padding: 0    
		
		Component.onCompleted: parent = Utils.getTopParent(this)
		
		onClosed: {	if(wrapper.delayClosing) closeDelay.restart()
			wrapper.closed()
		}
		onOpened: wrapper.opened()
	}
}
