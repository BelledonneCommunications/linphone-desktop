import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Item {
	id: mainItem
	property color indicatorColor: DefaultStyle.main1_500_main
	property alias indicatorHeight: busyIndicator.height
	property alias indicatorWidth: busyIndicator.width
	width: busyIndicator.width
	height: busyIndicator.height
	Control.BusyIndicator {
		id: busyIndicator
		width: Utils.getSizeWithScreenRatio(60)
		height: width
		running: mainItem.visible
		anchors.centerIn: mainItem
		contentItem: EffectImage {
			id: busyImage
			imageWidth: mainItem.width
			imageHeight: mainItem.height
			imageSource: AppIcons.busyIndicator
			colorizationColor: mainItem.indicatorColor
			RotationAnimator {
				target: busyImage
				running: busyIndicator.running
				from: 0
				to: 360
				loops: Animation.Infinite
				duration: 15000
			}
		}
	}
}
