import QtQuick
import QtQuick.Controls as Control
import QtQuick.Effects

import Linphone

Item {
	id: mainItem
	property color indicatorColor: DefaultStyle.main1_500_main
	width: busyIndicator.width
	height: busyIndicator.height
	Control.BusyIndicator {
		id: busyIndicator
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
                duration: 10000
            }
		}
	}
}