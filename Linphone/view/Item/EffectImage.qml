import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone

// The loader is needed here to refresh the colorization effect (effect2) which is not refreshed when visibility change
// and causes colorization issue when effect image is inside a popup
Loader {
	id: mainItem
	active: visible
	property var source
	property var fillMode: Image.PreserveAspectFit
	property var colorizationColor
	property int imageWidth: width
	property int imageHeight: height
	property bool useColor: colorizationColor != undefined
	sourceComponent: Item {
		Image {
			id: image
			visible: !effect2.enabled
			source: mainItem.source ? mainItem.source : ""
			fillMode: mainItem.fillMode
			sourceSize.width: width
			sourceSize.height: height
			width: mainItem.imageWidth
			height: mainItem.imageHeight
			anchors.centerIn: parent
		}
		MultiEffect {
			id: effect
			visible: false
			anchors.fill: image
			source: image
			maskSource: image
			brightness: effect2.enabled ? 1.0 : 0.0
		}

		MultiEffect {
			id: effect2
			visible: mainItem.useColor
			enabled: mainItem.useColor
			anchors.fill: effect
			source: effect
			maskSource: effect
			colorizationColor: effect2.enabled && mainItem.colorizationColor ? mainItem.colorizationColor : 'black'
			colorization: effect2.enabled ? 1.0: 0.0
		}
	}
}
