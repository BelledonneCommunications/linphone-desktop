import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone

Control.Control {
	id: mainItem
    // width: Math.round(360 * DefaultStyle.dp)
	property color backgroundColor: DefaultStyle.grey_0
    padding: Math.round(10 * DefaultStyle.dp)
	background: Rectangle {
		anchors.fill: parent
        radius: Math.round(15 * DefaultStyle.dp)
		color: mainItem.backgroundColor
	}
}
