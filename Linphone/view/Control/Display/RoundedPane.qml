import QtQuick
import QtQuick.Controls.Basic as Control
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Control {
	id: mainItem
    // width: Utils.getSizeWithScreenRatio(360)
	property color backgroundColor: DefaultStyle.grey_0
    padding: Utils.getSizeWithScreenRatio(10)
	background: Rectangle {
		anchors.fill: parent
        radius: Utils.getSizeWithScreenRatio(15)
		color: mainItem.backgroundColor
	}
}
