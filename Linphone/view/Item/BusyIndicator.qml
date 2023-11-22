import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
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
	}
	MultiEffect {
		source: busyIndicator
		anchors.fill: busyIndicator
		colorizationColor: mainItem.indicatorColor
		colorization: 1.0
	}
}