import QtQuick
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Item {
	id: mainItem
    property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property alias borderGradient: border.gradient
	property alias gradient: fill.gradient
	property alias color: fill.color
    property real radius
	Rectangle {
		id: border
		radius: mainItem.radius
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Horizontal
			GradientStop { position: 0.0; color: DefaultStyle.grey_0 }
			GradientStop { position: 1.0; color: DefaultStyle.grey_100 }
		}
		Rectangle {
			id: fill
			anchors.fill: parent
			anchors.margins: mainItem.borderWidth
            radius: mainItem.radius
		}
	}
}
