import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Button {
	id: mainItem
	textSize: Typography.b3.pixelSize
	textWeight: Typography.b3.weight
    leftPadding: Utils.getSizeWithScreenRatio(12)
    rightPadding: Utils.getSizeWithScreenRatio(12)
    topPadding: Utils.getSizeWithScreenRatio(6)
    bottomPadding: Utils.getSizeWithScreenRatio(6)
    icon.height: Utils.getSizeWithScreenRatio(14)
    icon.width: Utils.getSizeWithScreenRatio(14)
}
