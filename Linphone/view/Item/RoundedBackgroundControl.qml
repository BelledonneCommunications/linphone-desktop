import QtQuick
import QtQuick.Controls as Control
import Linphone

Control.Control {
	width: 360 * DefaultStyle.dp
	property color backgroundColor
	topPadding: 10 * DefaultStyle.dp
	bottomPadding: 10 * DefaultStyle.dp
	leftPadding: 10 * DefaultStyle.dp
	rightPadding: 10 * DefaultStyle.dp
	background: Rectangle {
		anchors.fill: parent
		radius: 15 * DefaultStyle.dp
		color: mainItem.backgroundColor ? mainItem.backgroundColor : DefaultStyle.grey_0
	}
}