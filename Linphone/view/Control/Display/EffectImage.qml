import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
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
    property real imageWidth: width
    property real imageHeight: height
	property bool useColor: colorizationColor != undefined
	property bool shadowEnabled: false
	property bool isImageReady: false
	asynchronous: true
	sourceComponent: Component{Item {
		Image {
			id: image
			visible: !effect2.effectEnabled
			source: mainItem.imageSource ? mainItem.imageSource : ""
			fillMode: mainItem.fillMode
			sourceSize.width: width
			sourceSize.height: height
			width: mainItem.imageWidth
			height: mainItem.imageHeight
			Layout.preferredWidth: mainItem.imageWidth
			Layout.preferredHeight: mainItem.imageHeight
			anchors.centerIn: parent
			onStatusChanged: mainItem.isImageReady = (status == Image.Ready)
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
            enabled: effectEnabled
			visible: mainItem.useColor
			property bool effectEnabled: mainItem.useColor
			anchors.fill: effect
			source: effect
			maskSource: effect
			colorizationColor: effectEnabled && mainItem.colorizationColor ? mainItem.colorizationColor : 'black'
			colorization: effectEnabled ? 1.0: 0.0
		}
		/* Alernative to shadow for no blackcolors
		MultiEffect {
			visible: mainItem.shadowEnabled
			source: image
			width: image.width
			height: image.height
			x: image.x
			y: image.y + 6
			z: -1
			blurEnabled: true
			blurMax: 12
			blur: 1.0
			contrast: -1.0
			brightness: 1.0
			colorizationColor: DefaultStyle.grey_400
			colorization: 1.0
		}*/
		MultiEffect {
			id: shadow
			enabled: mainItem.shadowEnabled
			anchors.fill: image
			source: image
			visible: mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730?
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0
			shadowOpacity: mainItem.shadowEnabled ? 0.7 : 0.0
			z: mainItem.z - 1
		}
	}
	}
}
