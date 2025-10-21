import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Button {
	id: mainItem
	textSize: Typography.b1.pixelSize
	textWeight: Typography.b1.weight
    leftPadding: Utils.getSizeWithScreenRatio(20)
    rightPadding: Utils.getSizeWithScreenRatio(20)
    topPadding: Utils.getSizeWithScreenRatio(11)
    bottomPadding: Utils.getSizeWithScreenRatio(11)
    icon.width: Utils.getSizeWithScreenRatio(24)
    icon.height: Utils.getSizeWithScreenRatio(24)
}
