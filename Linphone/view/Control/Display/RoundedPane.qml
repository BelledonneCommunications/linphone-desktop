import QtQuick
import QtQuick.Controls.Basic as Control
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
	}
}
