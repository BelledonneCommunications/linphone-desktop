import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone

Item {
	id: mainItem
	property alias image: image
	property alias effect: effect
	property alias effect2: effect2
	property var colorizationColor
	readonly property bool useColor: colorizationColor != undefined
	width: image.width
	height: image.height

	Image {
		id: image
		visible: !effect2.enabled
		sourceSize.width: parent.width
		sourceSize.height: parent.height
		width: parent.width
		height: parent.height
		fillMode: Image.PreserveAspectFit
		anchors.centerIn: parent
	}
	MultiEffect {
		id: effect
		visible: !effect2.enabled
		anchors.fill: image
		source: image
		maskSource: image
		brightness: effect2.enabled ? 1.0 : 0.0
	}
	MultiEffect {
		id: effect2
		enabled: mainItem.useColor
		anchors.fill: effect
		source: effect
		maskSource: effect
		colorizationColor: effect2.enabled ? mainItem.colorizationColor : 'black'
		colorization: effect2.enabled ? 1.0: 0.0
	}
}
