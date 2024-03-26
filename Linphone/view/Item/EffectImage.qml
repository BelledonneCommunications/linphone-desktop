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
	property var imageSource
	property var fillMode: Image.PreserveAspectFit
	property var colorizationColor
	property int imageWidth: width
	property int imageHeight: height
	property bool useColor: colorizationColor != undefined
	sourceComponent: Item {
		Image {
			id: image
			visible: !effect2.effectEnabled
			source: mainItem.imageSource ? mainItem.imageSource : ""
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
			brightness: effect2.effectEnabled ? 1.0 : 0.0
		}

		MultiEffect {
			id: effect2
			visible: mainItem.useColor
			property bool effectEnabled: mainItem.useColor
			anchors.fill: effect
			source: effect
			maskSource: effect
			colorizationColor: effectEnabled && mainItem.colorizationColor ? mainItem.colorizationColor : 'black'
			colorization: effectEnabled ? 1.0: 0.0
		}
	}
}
