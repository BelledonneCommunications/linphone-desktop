import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Button {
	id: mainItem
	textSize: Typography.p1s.pixelSize
	textWeight: Typography.p1s.weight
    padding: Utils.getSizeWithScreenRatio(16)
    // icon.width: width
    // icon.height: width
    radius: width * 2
    // width: Utils.getSizeWithScreenRatio(24)
    height: width
}
