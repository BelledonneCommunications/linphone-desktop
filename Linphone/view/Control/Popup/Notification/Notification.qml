import QtQuick 2.7
import QtQuick.Effects
import Linphone

// =============================================================================

DesktopPopup {
	id: mainItem
	
	
	property var notificationData: ({
										timelineModel : null
									})
	property int overriddenHeight: 120 * DefaultStyle.dp
	property int overriddenWidth: 300 * DefaultStyle.dp
	property double radius: 0
	default property alias _content: content.data
	
	signal deleteNotification (var notification)
	width: mainItem.overriddenWidth
	height: mainItem.overriddenHeight
	
	// Use as an intermediate between signal/slot without propagate the notification var : last signal parameter will be the last notification instance
	function deleteNotificationSlot(){
		deleteNotification(mainItem)
	}
	
	function _close (cb) {
		if (cb) {
			cb()
		}
		deleteNotificationSlot();
	}
	Rectangle {
		anchors.fill: parent
		visible: backgroundLoader.status != Loader.Ready
		color: DefaultStyle.grey_0
		radius: mainItem.radius
		border {
			color: DefaultStyle.grey_400
			width: 1 * DefaultStyle.dp
		}
	}
	
	Loader{
		id: backgroundLoader
		asynchronous: true
		sourceComponent: Item{
			width: mainItem.overriddenWidth
			height: mainItem.overriddenHeight
			Rectangle {
				id: background
				anchors.fill: parent
				visible: backgroundLoader.status != Loader.Ready
				color: DefaultStyle.grey_0
				radius: mainItem.radius
				border {
					color: DefaultStyle.grey_400
					width: 1 * DefaultStyle.dp
				}
			}
			MultiEffect {
				source: background
				anchors.fill: background
				shadowEnabled: true
				shadowColor: DefaultStyle.grey_1000
				shadowOpacity: 0.1
				shadowBlur: 0.1
			}
		}
	}
	Item {
		id: content
		anchors.fill: parent
	}
}
