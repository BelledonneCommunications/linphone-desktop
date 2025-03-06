import QtQuick
import Linphone

Item {
	id: mainItem
    property real borderWidth: Math.max(Math.round(1 * DefaultStyle.dp), 1)
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
