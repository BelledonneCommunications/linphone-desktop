import QtQuick 2.7
import Linphone

// =============================================================================

DesktopPopup {
	id: notification
	
	
	property var notificationData: ({
										timelineModel : null
									})
	property int overriddenHeight
	property int overriddenWidth
	default property alias _content: content.data
	
	signal deleteNotification (var notification)
	
	// Use as an intermediate between signal/slot without propagate the notification var : last signal parameter will be the last notification instance
	function deleteNotificationSlot(){
		deleteNotification(notification)
	}
	
	function _close (cb) {
		if (cb) {
			cb()
		}
		deleteNotificationSlot();
	}
	
	Rectangle {
		color: "#FFFFFF"
		height: overriddenHeight || 120
		width: overriddenWidth || 300
		
		border {
			color: "#A1A1A1"
			width: 1
		}
		
		Item {
			id: content
			
			anchors.fill: parent
		}
		
		Image {
			id: iconSign
			
			anchors {
				left: parent.left
				top: parent.top
			}
			
			
		}
	}
}
