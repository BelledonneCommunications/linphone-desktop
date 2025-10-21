import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.ScrollBar {
	id: mainItem
	padding: 0
    property color color: DefaultStyle.grey_850
	contentItem: Rectangle {
        implicitWidth: Utils.getSizeWithScreenRatio(6)
        radius: Utils.getSizeWithScreenRatio(32)
        color: mainItem.color
	}
}
