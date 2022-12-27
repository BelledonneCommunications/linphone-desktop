import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item{
	id: messageCounter
	property bool showOnlyNumber: false
	property int count: 0
	property alias icon: backgroundIcon.icon
	property alias iconSize: amountIcon.iconSize
	property int pointSize: MessageCounterStyle.text.pointSize
	
	visible: messageCounter.count > 0
	
	height: showOnlyNumber ? amountIcon.height : backgroundIcon.height
	width: showOnlyNumber ? amountIcon.width : backgroundIcon.width
	
	Icon {
		id: backgroundIcon
		icon: 'chat_count'
		iconSize: MessageCounterStyle.iconSize.message
		visible: !messageCounter.showOnlyNumber
	}
	Icon {
		id: amountIcon
		anchors {
			horizontalCenter: parent.right
			verticalCenter: parent.bottom
		}
		
		icon: 'chat_amount'
		iconSize: MessageCounterStyle.iconSize.amount
		visible: messageCounter.count > 0
		
		Text {
			anchors.centerIn: parent
			color: MessageCounterStyle.text.colorModel.color
			font.pointSize: messageCounter.pointSize
			text: (messageCounter.count>99 ? '+' : messageCounter.count)
		}
	}
}
