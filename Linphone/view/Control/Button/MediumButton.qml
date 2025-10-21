import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Button {
	id: mainItem
	textSize: Typography.b2.pixelSize
	textWeight: Typography.b2.weight
    leftPadding: Utils.getSizeWithScreenRatio(16)
    rightPadding: Utils.getSizeWithScreenRatio(16)
    topPadding: Utils.getSizeWithScreenRatio(10)
    bottomPadding: Utils.getSizeWithScreenRatio(10)
    icon.width: Utils.getSizeWithScreenRatio(16)
    icon.height: Utils.getSizeWithScreenRatio(16)
}
