import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone

Item {
	id: mainItem
	property alias image: image
	property alias effect: effect
	width: image.width
	height: image.height

	Image {
		id: image
		width: 20
		height: 20
		sourceSize.width: 20
		fillMode: Image.PreserveAspectFit
		anchors.centerIn: parent
	}
	MultiEffect {
		id: effect
		anchors.fill: image
		source: image
		maskSource: image
	}
}