import QtQuick
import QtQuick.Effects
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================

DesktopPopup {
	id: mainItem
	
	
	property var notificationData: ({
										timelineModel : null
									})
    property real overriddenHeight: Utils.getSizeWithScreenRatio(120)
    property real overriddenWidth: Utils.getSizeWithScreenRatio(300)
	property double radius: 0
	property color backgroundColor: DefaultStyle.grey_0
	property double backgroundOpacity: 1
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
		color: mainItem.backgroundColor
		radius: mainItem.radius
		opacity: mainItem.backgroundOpacity
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
				color: mainItem.backgroundColor
				radius: mainItem.radius
				opacity: mainItem.backgroundOpacity
				// border {
				// 	color: DefaultStyle.grey_400
                // 	width: Utils.getSizeWithScreenRatio(1)
				// }
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
