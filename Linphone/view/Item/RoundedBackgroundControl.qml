import QtQuick
import QtQuick.Controls as Control
import Linphone

Control.Control {
	id: mainItem
	// width: 360 * DefaultStyle.dp
	property color backgroundColor: DefaultStyle.grey_0
	padding: 10 * DefaultStyle.dp
	background: Rectangle {
		anchors.fill: parent
		radius: 15 * DefaultStyle.dp
		color: mainItem.backgroundColor
		anchors.leftMargin: 10 * DefaultStyle.dp
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.topMargin: 10 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
	}
}